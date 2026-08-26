#!/usr/bin/env python3
"""
Homogeneiza la geometría, el fondo y el contraste de los estímulos.

Qué iguala:
    - tamaño y encuadre (recorte centrado y redimensionado a NxN)
    - fondo, si existe máscara (`<nombre>_mask.png`, blanco = rostro)
    - contraste RMS, calculado dentro de la máscara o sobre la imagen entera

Qué NO iguala, a propósito:
    - la luminancia media, porque el tono de piel es la manipulación del estudio.
      Igualarla dejaría las tres versiones de cada conjunto indistinguibles en lo
      único que deben distinguirse.

El ajuste de contraste reescala cada píxel alrededor de la media de la imagen,
de modo que la media se conserva y la desviación típica pasa al valor objetivo.
Si no se indica objetivo, se usa la mediana del conjunto completo.

Uso:
    python normalizar_estimulos.py --entrada crudo/ --salida ../docs/estimulos/
    python normalizar_estimulos.py --entrada crudo/ --salida final/ --lado 512 --solo-informe
"""

import argparse
import csv
import pathlib
import sys

import numpy as np
from PIL import Image

FONDO_GRIS = (128, 128, 128)
PESOS_LUMA = np.array([0.2126, 0.7152, 0.0722])   # Rec. 709


def luma(arr):
    return arr.astype(np.float64) @ PESOS_LUMA


def estadisticos(arr, mascara=None):
    y = luma(arr)
    v = y[mascara] if mascara is not None else y.ravel()
    return {"media": float(v.mean()), "rms": float(v.std())}


def recuadrar(img, lado):
    """Recorte centrado al cuadrado y redimensionado a `lado` x `lado`."""
    a, b = img.size
    corte = min(a, b)
    izq, arriba = (a - corte) // 2, (b - corte) // 2
    return img.crop((izq, arriba, izq + corte, arriba + corte)).resize(
        (lado, lado), Image.LANCZOS)


def aplicar_fondo(arr, mascara):
    fuera = ~mascara
    salida = arr.copy()
    salida[fuera] = FONDO_GRIS
    return salida


def ajustar_rms(arr, objetivo, mascara=None):
    """Reescala el contraste conservando la media de luminancia."""
    y = luma(arr)
    v = y[mascara] if mascara is not None else y.ravel()
    actual = v.std()
    if actual < 1e-6:
        return arr
    factor = objetivo / actual
    media = v.mean()
    ajustado = (arr.astype(np.float64) - media) * factor + media
    return np.clip(ajustado, 0, 255).astype(np.uint8)


def carga_mascara(ruta_img):
    ruta = ruta_img.with_name(ruta_img.stem + "_mask.png")
    if not ruta.exists():
        return None
    m = np.array(Image.open(ruta).convert("L"))
    return m > 127


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--entrada", required=True)
    ap.add_argument("--salida", required=True)
    ap.add_argument("--lado", type=int, default=512)
    ap.add_argument("--objetivo-rms", type=float, default=None,
                    help="por defecto, la mediana del conjunto")
    ap.add_argument("--solo-informe", action="store_true",
                    help="calcula y escribe el informe sin guardar imágenes")
    ap.add_argument("--informe", default="informe_normalizacion.csv")
    args = ap.parse_args()

    entrada = pathlib.Path(args.entrada)
    salida = pathlib.Path(args.salida)
    rutas = sorted(p for p in entrada.iterdir()
                   if p.suffix.lower() in {".png", ".jpg", ".jpeg"}
                   and not p.stem.endswith("_mask"))
    if not rutas:
        sys.exit("No hay imágenes en %s" % entrada)

    # Primera pasada: geometría y estadísticos de partida.
    cargadas = []
    for p in rutas:
        img = recuadrar(Image.open(p).convert("RGB"), args.lado)
        arr = np.array(img)
        m = carga_mascara(p)
        if m is not None:
            m = np.array(Image.fromarray(m.astype(np.uint8) * 255).resize(
                (args.lado, args.lado), Image.NEAREST)) > 127
            arr = aplicar_fondo(arr, m)
        cargadas.append((p, arr, m, estadisticos(arr, m)))

    objetivo = args.objetivo_rms
    if objetivo is None:
        objetivo = float(np.median([e["rms"] for _, _, _, e in cargadas]))

    if not args.solo_informe:
        salida.mkdir(parents=True, exist_ok=True)

    filas = []
    for p, arr, m, antes in cargadas:
        final = ajustar_rms(arr, objetivo, m)
        despues = estadisticos(final, m)
        if not args.solo_informe:
            Image.fromarray(final).save(salida / (p.stem + ".png"))
        filas.append({
            "archivo": p.name,
            "lado": args.lado,
            "mascara": int(m is not None),
            "luminancia_media_antes": round(antes["media"], 2),
            "luminancia_media_despues": round(despues["media"], 2),
            "rms_antes": round(antes["rms"], 2),
            "rms_despues": round(despues["rms"], 2),
            "rms_objetivo": round(objetivo, 2),
        })

    ruta_informe = (salida if not args.solo_informe else entrada) / args.informe
    with open(ruta_informe, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=list(filas[0].keys()))
        w.writeheader()
        w.writerows(filas)

    desv = max(abs(f["rms_despues"] - objetivo) for f in filas)
    print("Imágenes procesadas: %d" % len(filas))
    print("RMS objetivo: %.2f | desviación máxima tras el ajuste: %.2f" % (objetivo, desv))
    print("La luminancia media NO se iguala: el tono de piel es la manipulación.")
    print("Informe: %s" % ruta_informe)
    if desv > 1.0:
        print("AVISO: alguna imagen no alcanza el objetivo, probablemente por recorte a 0-255.")


if __name__ == "__main__":
    main()
