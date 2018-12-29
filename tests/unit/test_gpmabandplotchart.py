import unittest

from gpchart.gpmabandplotchart import GpdbMABandPlotChart
import matplotlib as mpl
import os.path # for checking file
import os      # for removing test file
import base64  # for decoding from base64
import imghdr  # for checking image format

class TestMABandPlotChart(unittest.TestCase):

    def test_save_fig(self):
        '''
        This tests if the plot is saved with file.
        We only check whether the file is exsist and
            do not check whether the plot was drawn rightly.
        '''
        filename = "ma_band_plot_unit_test.png"
        OPTIONS = '''{
            "style":"bmh",
            "figure.figsize": [12.0, 6.0],
            "legend.loc":"upper right",
            "axes.color_pallete":["#173F5F", "#20639B", "#ED553B", "#3CAEA3", "#F6D55C"],
            "axes.color_alpha":0.7,
            "axes.band_color" : "#F6D55C",
            "axes.band_color_alpha" : 0.3
            }'''
        chart = GpdbMABandPlotChart('test', OPTIONS, 3, 2.0)
        chart.draw_chart([1, 2, 3, 4, 5, 6, 7, 8, 9],
                         [1, 2, 3, 4, 5, 6, 4, 2, 6],
                         ['A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A'])
        chart.save_file(filename)
        assert os.path.isfile(filename), "Plot does not saved."
        try:
            os.remove(filename)
        except OSError as e:
            print ("Error: %s - %s." % (e.filename, e.strerror))

if __name__ == '__main__':
    unittest.main()
