"""Independent Python reference for AgroClim degree-day calculations."""

from __future__ import annotations

import math


def edd(tmin: float, tmax: float, threshold: float) -> float:
    """Analytic sinusoidal exceedance degree-days."""
    if tmin > tmax:
        raise ValueError("tmin must not exceed tmax")
    mean = 0.5 * (tmin + tmax)
    amplitude = 0.5 * (tmax - tmin)
    if amplitude <= float.fromhex("0x1.0p-52"):
        return max(mean - threshold, 0.0)
    if threshold >= tmax:
        return 0.0
    if threshold <= tmin:
        return mean - threshold
    ratio = max(-1.0, min(1.0, (threshold - mean) / amplitude))
    theta = math.acos(ratio)
    return max((amplitude * math.sin(theta) + (mean - threshold) * theta) / math.pi, 0.0)


def gdd(tmin: float, tmax: float, base: float, cap: float) -> float:
    """Capped degree-days, expressed as the difference of two EDD integrals."""
    if cap <= base:
        raise ValueError("cap must exceed base")
    return max(0.0, min(cap - base, edd(tmin, tmax, base) - edd(tmin, tmax, cap)))


def hdd(tmin: float, tmax: float, threshold: float) -> float:
    """Cold degree-days below a threshold."""
    mean = 0.5 * (tmin + tmax)
    return max(threshold - mean + edd(tmin, tmax, threshold), 0.0)
