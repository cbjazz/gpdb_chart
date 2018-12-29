import unittest

from gpchart.gpplotchart import GpdbPlotChart
import matplotlib as mpl

class TestPlotChart(unittest.TestCase):
    def test_options(self):
        '''
        This tests the matplotlib style.
        In here, we only checked
            if the legend location and marker are set as we wish.
        '''
        options = '''{
            "legend.loc":"lower center",
            "lines.marker":"o"
        }'''
        chart = GpdbPlotChart('test', options)
        chart.draw_chart([1,2,3], [1,2,3], ['A', 'A', 'A'], [1,1,1])
        assert mpl.rcParams['lines.marker']=='o' , "Marker does not set."
        assert mpl.rcParams['legend.loc']=="lower center", \
            "Legend loc does not set."

if __name__ == '__main__':
    unittest.main()
