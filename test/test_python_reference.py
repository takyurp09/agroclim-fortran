import random
import unittest

from python.quadrature_oracle import edd_quadrature, gdd_quadrature, hdd_quadrature
from python.reference_indices import edd, gdd, hdd


class ReferenceTests(unittest.TestCase):
    def test_known_capped_case(self):
        self.assertAlmostEqual(gdd(0.0, 40.0, 10.0, 30.0), 10.0, places=12)

    def test_against_quadrature(self):
        random.seed(20260720)
        for _ in range(20):
            tmin = random.uniform(-15.0, 30.0)
            tmax = tmin + random.uniform(0.0, 30.0)
            threshold = random.uniform(0.0, 35.0)
            self.assertAlmostEqual(
                edd(tmin, tmax, threshold),
                edd_quadrature(tmin, tmax, threshold, steps=40_000),
                delta=2.0e-6,
            )
            self.assertAlmostEqual(
                hdd(tmin, tmax, threshold),
                hdd_quadrature(tmin, tmax, threshold, steps=40_000),
                delta=2.0e-6,
            )
            self.assertAlmostEqual(
                gdd(tmin, tmax, 8.0, 30.0),
                gdd_quadrature(tmin, tmax, 8.0, 30.0, steps=40_000),
                delta=2.0e-6,
            )


if __name__ == "__main__":
    unittest.main()
