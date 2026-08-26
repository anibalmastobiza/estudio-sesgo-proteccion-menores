#!/usr/bin/env python3
"""
Construye los estímulos del estudio a partir de AI-Faces by Illinois.

AI-Faces by Illinois (Ross, Vasquez, Rodriguez y cols., OSF: https://osf.io/vurm5/,
CC BY-NC 4.0) es una base abierta de 1.152 caras infantiles fotorrealistas
generadas con IA, que varían de forma sistemática en edad aparente (3, 6, 10 y
15 años), sexo, ocho categorías raciales y expresión, con datos normativos de
jueces adultos para edad, realismo, masculinidad, emoción y percepción racial.

Qué hace este script:

  1. Lee el índice de los ZIP de OSF por peticiones de rango, sin descargar los
     640 MB completos, y extrae solo las caras de chicos de 15 años.
  2. Descarga la matriz normativa y comprueba el emparejamiento entre condiciones.
  3. Busca el subconjunto más grande cuyas condiciones queden emparejadas en edad
     percibida y masculinidad, que son los dos desajustes reales de esta base.
  4. Compone las caras sobre fondo gris uniforme, las lleva a 512 px y las guarda.
  5. Escribe docs/estimulos/manifiesto.json y la tabla de normas.

Por qué hace falta emparejar: en el conjunto completo, las caras negras de 15
años se perciben 1,2 años MÁS MAYORES que las blancas (p = .030) y más
masculinas (p < .001). Ese desajuste apunta en la misma dirección que la
hipótesis de adultificación, de modo que usarlo sin corregir metería la
conclusión dentro de los estímulos.

Uso:
    python estimulos/preparar_aifaces.py
    python estimulos/preparar_aifaces.py --max-dif-edad 0.35 --lado 512
"""

import argparse
import itertools
import json
import os
import pathlib
import struct
import subprocess
import sys
import zlib

OSF_NODO = "vurm5"
API = "https://api.osf.io/v2/nodes/%s/files/osfstorage/" % OSF_NODO
NORMAS_URL = "https://osf.io/download/6r23g/"

# Prefijo de archivo -> condición del estudio.
CONDICIONES = {"W": "no_racializado", "B": "subsahariano"}

# Columna de la matriz normativa que debe dominar en cada condición.
RATING = {"no_racializado": "White_Mean", "subsahariano": "Black_Mean"}

FONDO = (128, 128, 128)

# La expresión es un FACTOR CRUZADO con el fenotipo: el diseño es 2 x 2 y cada
# participante ve una sola cara. Así se puede estimar el efecto del fenotipo, el
# de la expresión y su interacción, en vez de suponer que la expresión no
# importa.
#
# El nivel negativo junta ceñudas y enfadadas. Las ceñudas por separado son las
# únicas genuinamente tristes (tristeza 4.83 sobre 7 frente a 2.84 de las
# enfadadas), pero solo hay cuatro por condición y no se dejan emparejar: el
# mejor subconjunto deja 1.04 DT de diferencia en masculinidad y realismo. Con
# las dos juntas sí se emparejan. La consecuencia es que el nivel negativo mezcla
# tristeza y enfado, y por eso el cuestionario pregunta de forma expresa cómo se
# percibe la emoción en lugar de darla por supuesta.
ESTRATOS = {"S": "contento", "F": "afligido", "A": "afligido"}

# Variables normativas que deben quedar emparejadas dentro de cada estrato.
# La emoción lleva un criterio propio y más estricto: una cara que se percibe
# más triste atrae más protección, de modo que un desajuste de tristeza entre
# condiciones se sumaría directamente al efecto que el estudio quiere medir.
# La masculinidad y el realismo admiten más holgura porque entran como
# covariables de nivel de imagen en la comprobación de robustez.
VARS_EMOCION   = ["feliz", "triste", "enfadado"]
VARS_RESTO     = ["edad", "masc", "real"]
VARS_EMPAREJAR = VARS_EMOCION + VARS_RESTO


def curl(url, rango=None, binario=True):
    cmd = ["curl", "-sL"]
    if rango:
        cmd += ["-r", "%d-%d" % rango]
    cmd.append(url)
    r = subprocess.run(cmd, capture_output=True, check=True)
    return r.stdout if binario else r.stdout.decode("utf-8")


def indice_zip(url, total):
    """Lee el directorio central del ZIP remoto sin bajarlo entero."""
    cola = curl(url, (max(0, total - 300000), total - 1))
    i = cola.rfind(b"PK\x05\x06")
    if i < 0:
        raise RuntimeError("no se encuentra el fin del directorio central")
    _, tam_cd, off_cd = struct.unpack("<HII", cola[i + 10:i + 20])
    cd = curl(url, (off_cd, off_cd + tam_cd - 1))
    entradas, p = [], 0
    while p < len(cd) - 4 and cd[p:p + 4] == b"PK\x01\x02":
        metodo, = struct.unpack("<H", cd[p + 10:p + 12])
        csize, usize = struct.unpack("<II", cd[p + 20:p + 28])
        ln, le, lc = struct.unpack("<HHH", cd[p + 28:p + 34])
        lho, = struct.unpack("<I", cd[p + 42:p + 46])
        entradas.append({"nombre": cd[p + 46:p + 46 + ln].decode("utf-8", "replace"),
                         "metodo": metodo, "csize": csize, "usize": usize, "lho": lho})
        p += 46 + ln + le + lc
    return entradas


def extrae(url, e, destino):
    lh = curl(url, (e["lho"], e["lho"] + 29))
    if lh[:4] != b"PK\x03\x04":
        raise RuntimeError("cabecera local invalida en " + e["nombre"])
    ln, le = struct.unpack("<HH", lh[26:30])
    ini = e["lho"] + 30 + ln + le
    datos = curl(url, (ini, ini + e["csize"] - 1))
    if e["metodo"] == 8:
        datos = zlib.decompress(datos, -15)
    elif e["metodo"] != 0:
        raise RuntimeError("metodo de compresion %d no soportado" % e["metodo"])
    if len(datos) != e["usize"]:
        raise RuntimeError("tamano inesperado en " + e["nombre"])
    pathlib.Path(destino).write_bytes(datos)


def pid(nombre):
    """W_B_15_S_001.png -> WB15S001, la clave de la matriz normativa."""
    p = os.path.basename(nombre)[:-4].split("_")
    return "".join(p[:5]).upper()


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--max-dif-emocion", type=float, default=0.25,
                    help="desajuste máximo admitido en felicidad, tristeza y enfado, "
                         "en desviaciones típicas, dentro de cada estrato")
    ap.add_argument("--max-dif", type=float, default=0.60,
                    help="desajuste máximo admitido en edad, masculinidad y realismo, "
                         "en desviaciones típicas, dentro de cada estrato")
    ap.add_argument("--lado", type=int, default=512)
    ap.add_argument("--crudo", default="estimulos/crudo")
    ap.add_argument("--salida", default="docs/estimulos")
    args = ap.parse_args()

    try:
        import pandas as pd
        import numpy as np
        from PIL import Image
    except ImportError as e:
        sys.exit("Falta una dependencia: %s. Instale pandas, numpy y pillow." % e)

    crudo = pathlib.Path(args.crudo); crudo.mkdir(parents=True, exist_ok=True)
    salida = pathlib.Path(args.salida)

    # ---------------------------------------------------------- 1. descarga --
    print("1. Índice de OSF")
    ficheros = json.loads(curl(API, binario=False))["data"]
    zips = {f["attributes"]["name"]: (f["links"]["download"], f["attributes"]["size"])
            for f in ficheros if f["attributes"]["name"].endswith(".zip")}

    # Ronda 2: blancos, negros, latinos, asiáticos. Ronda 6: el resto.
    quiero = {"Round 2": ["/W_B_15_S/", "/W_B_15_F/", "/W_B_15_A/",
                          "/B_B_15_S/", "/B_B_15_F/", "/B_B_15_A/"]}
    for nombre, (url, total) in zips.items():
        clave = next((k for k in quiero if nombre.startswith(k)), None)
        if not clave or "10 and 15" not in nombre:
            continue
        print("   leyendo %s" % nombre)
        for e in indice_zip(url, total):
            if e["usize"] and any(p in e["nombre"] for p in quiero[clave]):
                destino = crudo / os.path.basename(e["nombre"])
                if not destino.exists():
                    extrae(url, e, destino)
    caras = sorted(p for p in crudo.iterdir() if p.suffix.lower() == ".png")
    print("   caras disponibles: %d" % len(caras))
    if not caras:
        sys.exit("No se ha extraído ninguna cara. Revise la conexión con OSF.")

    # ---------------------------------------------------- 2. matriz normativa --
    print("2. Matriz normativa")
    ruta_normas = crudo / "aifaces_norming.csv"
    if not ruta_normas.exists():
        ruta_normas.write_bytes(curl(NORMAS_URL))
    norm = pd.read_csv(ruta_normas, low_memory=False).set_index("Picture_ID")

    filas = []
    for p in caras:
        k = pid(p.name)
        if k not in norm.index:
            print("   sin normas, se descarta: %s" % p.name); continue
        r = norm.loc[k]
        expr = p.name.split("_")[3].upper()
        filas.append(dict(archivo=p.name, pid=k, cond=CONDICIONES[p.name[0].upper()],
                          expr=expr, estrato=ESTRATOS[expr],
                          edad=r.Age_Mean, edad_dt=r.Age_SD, real=r.Real_Mean,
                          masc=r.Masculine_Mean, feliz=r.Happy_Mean, triste=r.Sad_Mean,
                          enfadado=r.Angry_Mean, majo=r.Nice_Mean, rico=r.Wealthy_Mean,
                          rating_propio=r[RATING[CONDICIONES[p.name[0].upper()]]]))
    d = pd.DataFrame(filas)
    print("   desajuste en el conjunto completo:")
    for v in ["edad", "masc", "real", "feliz"]:
        a = d[d.cond == "no_racializado"][v].mean(); b = d[d.cond == "subsahariano"][v].mean()
        print("     %-6s no racializado %.2f  subsahariano %.2f  diferencia %+.2f" % (v, a, b, a - b))

    # ------------------------------------------------------ 3. emparejamiento --
    print("3. Emparejamiento dentro de cada estrato de expresión")
    dt = {v: d[v].std() for v in VARS_EMPAREJAR}

    def difs(ca, cb):
        return {v: abs(d.loc[list(ca), v].mean() - d.loc[list(cb), v].mean()) / dt[v]
                for v in VARS_EMPAREJAR}

    def cumple(x):
        return (max(x[v] for v in VARS_EMOCION) <= args.max_dif_emocion and
                max(x[v] for v in VARS_RESTO) <= args.max_dif)

    def coste(x):
        # Prioriza la emoción: un exceso ahí pesa el doble que en el resto.
        return 2 * max(x[v] for v in VARS_EMOCION) + max(x[v] for v in VARS_RESTO)

    seleccion = {c: [] for c in CONDICIONES.values()}
    estratos_usados = {}
    for estrato in sorted(set(ESTRATOS.values())):
        A = d[(d.cond == "no_racializado") & (d.estrato == estrato)].index.tolist()
        B = d[(d.cond == "subsahariano") & (d.estrato == estrato)].index.tolist()
        elegido = None
        for k in range(min(len(A), len(B)), 1, -1):
            mejor = None
            for ca in itertools.combinations(A, k):
                for cb in itertools.combinations(B, k):
                    x = difs(ca, cb)
                    c = coste(x)
                    if mejor is None or c < mejor[0]:
                        mejor = (c, ca, cb, x)
            x = mejor[3]
            print("   %-9s k=%-2d  emoción %.3f  resto %.3f" %
                  (estrato, k, max(x[v] for v in VARS_EMOCION), max(x[v] for v in VARS_RESTO)))
            if cumple(x):
                elegido = mejor
                break
        if elegido is None:
            print("   %-9s NINGÚN subconjunto cumple los criterios. Estrato descartado."
                  % estrato)
            continue
        x = elegido[3]
        estratos_usados[estrato] = {
            "k": len(elegido[1]),
            "dif_max_emocion": round(float(max(x[v] for v in VARS_EMOCION)), 3),
            "dif_max_resto": round(float(max(x[v] for v in VARS_RESTO)), 3),
            "difs": {v: round(float(x[v]), 3) for v in VARS_EMPAREJAR}}
        for i in elegido[1]:
            seleccion["no_racializado"].append((d.loc[i, "archivo"], estrato))
        for i in elegido[2]:
            seleccion["subsahariano"].append((d.loc[i, "archivo"], estrato))

    if not estratos_usados:
        sys.exit("Ningún estrato se puede emparejar. Revise --max-dif.")
    for cond in seleccion:
        seleccion[cond].sort()
    print("   estratos usados: %s" % estratos_usados)
    print("   caras por condición: %d" % len(seleccion["no_racializado"]))

    # ------------------------------------------------------- 4. procesamiento --
    print("4. Procesamiento de imagen")
    dir_img = salida / "aifaces"
    dir_img.mkdir(parents=True, exist_ok=True)
    manifiesto_caras = {}
    for cond, archivos in seleccion.items():
        manifiesto_caras[cond] = {}
        for a, estrato in archivos:
            im = Image.open(crudo / a).convert("RGBA")
            fondo = Image.new("RGBA", im.size, FONDO + (255,))
            plano = Image.alpha_composite(fondo, im).convert("RGB")
            plano = plano.resize((args.lado, args.lado), Image.LANCZOS)
            nombre = a.lower()
            plano.save(dir_img / nombre, optimize=True)
            manifiesto_caras[cond].setdefault(estrato, []).append("aifaces/" + nombre)
    n_img = sum(len(lista) for v in manifiesto_caras.values() for lista in v.values())
    print("   %d imágenes a %d px sobre fondo gris uniforme" % (n_img, args.lado))

    # Las cuatro casillas del diseño 2 x 2 tienen que existir y tener el mismo
    # número de caras en las dos condiciones: si no, la expresión y el fenotipo
    # dejarían de estar cruzados.
    comp = {c: {k: len(v) for k, v in manifiesto_caras[c].items()} for c in manifiesto_caras}
    refs = list(comp.values())
    if any(r != refs[0] for r in refs[1:]):
        sys.exit("Composición de expresiones distinta entre condiciones: %s.\n"
                 "El diseño 2 x 2 quedaría desequilibrado. Ajuste los criterios." % comp)
    print("   casillas del diseño 2 x 2: %s caras por expresión, en cada fenotipo" % refs[0])

    # ---------------------------------------------------------- 5. manifiesto --
    elegidos = [a for cond in seleccion for a, _ in seleccion[cond]]
    sub = d[d.archivo.isin(elegidos)]
    normas = {}
    for cond in seleccion:
        normas[cond] = {}
        for estrato in sorted(set(ESTRATOS.values())):
            t = sub[(sub.cond == cond) & (sub.estrato == estrato)]
            if len(t):
                normas[cond][estrato] = {v: round(float(t[v].mean()), 3)
                                         for v in ("edad", "masc", "real", "feliz", "triste",
                                                   "enfadado", "majo", "rico", "rating_propio")}

    manifiesto = {
        "version": "1.0-aifaces",
        "estructura": "anidada",
        "nota": ("Estímulos tomados de AI-Faces by Illinois (OSF vurm5, CC BY-NC 4.0), "
                 "chicos con edad objetivo de 15 años. Las caras son identidades "
                 "independientes, de modo que el estímulo va ANIDADO en la casilla del "
                 "diseño. La expresión, en cambio, está CRUZADA con el fenotipo."),
        "fuente": {"nombre": "AI-Faces by Illinois", "osf": "https://osf.io/vurm5/",
                   "licencia": "CC BY-NC 4.0",
                   "atribucion": "AI-Faces by Illinois, University of Illinois, OSF vurm5, CC BY-NC 4.0"},
        "condiciones": list(seleccion.keys()),
        "condicion_ausente": {
            "magrebi": ("Descartada. En la matriz normativa, solo 3 de las 18 caras de chicos "
                        "etiquetadas como norteafricanas o de Oriente Medio son percibidas "
                        "mayoritariamente como tales; 9 se perciben como blancas y 4 como latinas. "
                        "El contraste magrebí se estudia con la variante de nombre.")},
        "diseno": "2 x 2: fenotipo (no racializado, subsahariano) x expresion (afligido, contento)",
        "expresiones": sorted(refs[0].keys()),
        "composicion_por_codigo": {c: sorted(a.split("_")[3].lower()
                                             for a, _ in seleccion[c]) for c in seleccion},
        "seleccion": {"criterio_max_dif_emocion": args.max_dif_emocion,
                      "criterio_max_dif_resto": args.max_dif,
                      "variables_emparejadas": VARS_EMPAREJAR,
                      "por_estrato": estratos_usados},
        "regla_de_presentacion": ("Cada participante ve UNA sola cara, sorteada entre las "
                                  "cuatro casillas del diseño con igual probabilidad. La "
                                  "expresión percibida se mide con un ítem propio."),
        "normas": normas,
        "n_caras": {k: sum(len(x) for x in v.values()) for k, v in manifiesto_caras.items()},
        "caras": manifiesto_caras
    }
    (salida / "manifiesto.json").write_text(
        json.dumps(manifiesto, ensure_ascii=False, indent=2), encoding="utf-8")
    sub.to_csv(salida.parent.parent / "estimulos" / "normas_seleccionadas.csv",
               index=False, encoding="utf-8")
    print("5. Escrito %s y estimulos/normas_seleccionadas.csv" % (salida / "manifiesto.json"))
    print("\nRecuerde: la atribución CC BY-NC debe aparecer en el artículo y en la web.")


if __name__ == "__main__":
    main()
