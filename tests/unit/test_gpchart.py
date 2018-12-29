import unittest

from gpchart.gpplotchart import GpdbPlotChart
import matplotlib as mpl
import os.path
import os

class TestSum(unittest.TestCase):

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

    def test_save_fig(self):
        '''
        This tests if the plot is saved with file.
        We only check whether the file is exsist and
            do not check whether the plot was drawn rightly.
        '''
        options = '''{
            "style":"bmh",
            "figure.figsize": [12.0, 6.0],
            "legend.loc":"upper right",
            "lines.marker":"o",
            "axes.color_map":"PuOr",
            "axes.color_alpha":0.7
        }'''
        filename = "unit_test.png"
        chart = GpdbPlotChart('test', options)
        chart.draw_chart([1,2,3], [1,2,3], ['A', 'A', 'A'], [1,1,1])
        chart.save_file(filename)
        assert os.path.isfile(filename), "Plot does not saved."
        try:
            os.remove(filename)
        except OSError as e:
            print ("Error: %s - %s." % (e.filename, e.strerror))


if __name__ == '__main__':
    unittest.main()
