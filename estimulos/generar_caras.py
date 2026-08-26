#!/usr/bin/env python3
"""
Generación de conjuntos de estímulo por mezcla de estilos con StyleGAN2-ADA.

ESTE SCRIPT NO SE HA EJECUTADO. Requiere GPU, los pesos del modelo y el
repositorio de NVIDIA en el PYTHONPATH. Está escrito como registro de las
decisiones que hay que tomar y como punto de partida, y no como herramienta
terminada. Verifique cada paso antes de fiarse de la salida.

Idea, tomada de la GAN Face Database (ganfd.com):

    w_identidad   controla estructura facial, pose y expresión  -> capas bajas
    w_fenotipo    controla tono de piel, textura de pelo, rasgos -> capas altas

Cruzando una w_identidad con tres w_fenotipo se obtiene un conjunto: la misma
cara con tres fenotipos percibidos distintos. El corte entre capas (CORTE) es el
parámetro que hay que calibrar a ojo: demasiado bajo cambia la identidad,
demasiado alto no cambia el fenotipo lo suficiente.

Nada de esto sustituye a la revisión visual ni al estudio normativo. La salida
de este script son candidatos, no estímulos.

Uso previsto:
    python generar_caras.py --pesos ffhq.pkl --n-identidades 40 --salida crudo/
"""

import argparse
import json
import pathlib

# Dependencias que hay que instalar aparte: torch, numpy, pillow y el
# repositorio stylegan2-ada-pytorch de NVIDIA (import dnnlib, legacy).

CONDICIONES = ["no_racializado", "magrebi", "subsahariano"]

# Capas por debajo de este índice llevan la identidad; por encima, el fenotipo.
# En StyleGAN2 a 1024 px hay 18 capas de estilo. 8 es un punto de partida.
CORTE = 8

# Semillas de los vectores de fenotipo. Se fijan a mano tras inspeccionar
# muestras: hay que elegir semillas cuyo fenotipo sea claro y cuya edad aparente
# esté en el rango adolescente. Sustituya estos valores por los suyos.
SEMILLAS_FENOTIPO = {
    "no_racializado": [1001, 1002, 1003],
    "magrebi":        [2001, 2002, 2003],
    "subsahariano":   [3001, 3002, 3003],
}


def cargar_generador(ruta_pesos, dispositivo):
    """Carga el generador. Requiere dnnlib y legacy de stylegan2-ada-pytorch."""
    import dnnlib, legacy  # noqa: F401
    with dnnlib.util.open_url(str(ruta_pesos)) as f:
        return legacy.load_network_pkl(f)["G_ema"].to(dispositivo)


def w_de_semilla(G, semilla, dispositivo, truncamiento=0.7):
    """Vector de estilo w a partir de una semilla, con truncamiento."""
    import numpy as np, torch
    z = torch.from_numpy(np.random.RandomState(semilla).randn(1, G.z_dim)).to(dispositivo)
    return G.mapping(z, None, truncation_psi=truncamiento)


def mezclar(G, w_identidad, w_fenotipo, corte=CORTE):
    """Capas bajas de la identidad, capas altas del fenotipo."""
    w = w_identidad.clone()
    w[:, corte:, :] = w_fenotipo[:, corte:, :]
    return w


def sintetizar(G, w):
    import numpy as np
    from PIL import Image
    img = G.synthesis(w, noise_mode="const")
    img = (img.permute(0, 2, 3, 1) * 127.5 + 128).clamp(0, 255).to("cpu").numpy()
    return Image.fromarray(img[0].astype(np.uint8), "RGB")


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--pesos", required=True, help="ruta al .pkl del generador")
    ap.add_argument("--n-identidades", type=int, default=40)
    ap.add_argument("--semilla-base", type=int, default=20260826)
    ap.add_argument("--truncamiento", type=float, default=0.7)
    ap.add_argument("--corte", type=int, default=CORTE)
    ap.add_argument("--salida", default="crudo")
    ap.add_argument("--dispositivo", default="cuda")
    args = ap.parse_args()

    salida = pathlib.Path(args.salida)
    salida.mkdir(parents=True, exist_ok=True)

    G = cargar_generador(args.pesos, args.dispositivo)

    # Un vector de fenotipo por condición: promedio de sus semillas, lo que
    # atenúa la idiosincrasia de cualquier semilla concreta.
    w_fen = {}
    for cond, semillas in SEMILLAS_FENOTIPO.items():
        ws = [w_de_semilla(G, s, args.dispositivo, args.truncamiento) for s in semillas]
        w_fen[cond] = sum(ws) / len(ws)

    registro = []
    for i in range(args.n_identidades):
        semilla_id = args.semilla_base + i
        w_id = w_de_semilla(G, semilla_id, args.dispositivo, args.truncamiento)
        conjunto = "C%03d" % (i + 1)
        for cond in CONDICIONES:
            img = sintetizar(G, mezclar(G, w_id, w_fen[cond], args.corte))
            nombre = "%s_%s.png" % (conjunto, cond)
            img.save(salida / nombre)
            registro.append({"conjunto": conjunto, "condicion": cond, "archivo": nombre,
                             "semilla_identidad": semilla_id,
                             "semillas_fenotipo": SEMILLAS_FENOTIPO[cond],
                             "corte": args.corte, "truncamiento": args.truncamiento})

    (salida / "registro_generacion.json").write_text(
        json.dumps({"pesos": str(args.pesos), "imagenes": registro},
                   ensure_ascii=False, indent=2), encoding="utf-8")

    print("Generados %d candidatos en %s." % (len(registro), salida))
    print("Siguiente paso: revisión visual, después normalizar_estimulos.py.")
    print("Descarte sin contemplaciones: artefactos, edad fuera de 13-16, expresión no neutra,")
    print("y cualquier conjunto en el que las tres versiones no parezcan la misma persona.")


if __name__ == "__main__":
    main()
