import unittest

from gpchart.gpchart import GpdbChart
import matplotlib as mpl

class TestSum(unittest.TestCase):

    def test_options(self):
        options = '''{
            "style":"bmh",
            "figure.figsize": [12.0, 6.0],
            "legend.loc":"lower center",
            "lines.marker":"o",
            "axes.color_map":"PuOr",
            "axes.color_alpha":0.7
        }'''
        chart = GpdbChart('test', options)
        chart.draw_chart([1,2,3], [1,2,3], ['A', 'A', 'A'], [1,1,1])
        assert mpl.rcParams['lines.marker']=='o' , "Marker does not set."
        assert mpl.rcParams['legend.loc']=="lower center", "legend does not set"

if __name__ == '__main__':
    unittest.main()
