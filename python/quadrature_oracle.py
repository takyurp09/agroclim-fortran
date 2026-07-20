"""Numerical-integration oracle independent of the analytic implementation."""

from __future__ import annotations

import math


def integrate_daily(
    tmin: float,
    tmax: float,
    transform,
    steps: int = 100_000,
) -> float:
    """Midpoint integration of a sinusoidal daily temperature curve."""
    mean = 0.5 * (tmin + tmax)
    amplitude = 0.5 * (tmax - tmin)
    total = 0.0
    for index in range(steps):
        phase = 2.0 * math.pi * (index + 0.5) / steps
        temperature = mean + amplitude * math.sin(phase)
        total += transform(temperature)
    return total / steps


def edd_quadrature(tmin: float, tmax: float, threshold: float, steps: int = 100_000) -> float:
    return integrate_daily(tmin, tmax, lambda temp: max(temp - threshold, 0.0), steps)


def gdd_quadrature(
    tmin: float,
    tmax: float,
    base: float,
    cap: float,
    steps: int = 100_000,
) -> float:
    return integrate_daily(tmin, tmax, lambda temp: min(max(temp - base, 0.0), cap - base), steps)


def hdd_quadrature(tmin: float, tmax: float, threshold: float, steps: int = 100_000) -> float:
    return integrate_daily(tmin, tmax, lambda temp: max(threshold - temp, 0.0), steps)
