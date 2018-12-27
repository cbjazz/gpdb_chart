import unittest

from gpchart.gpchart import sum_test

class TestSum(unittest.TestCase):

    def test_init(self):
        data = [1, 2, 3]
        result = sum_test(data)
        self.assertEqual(result, 6)

if __name__ == '__main__':
    unittest.main()
