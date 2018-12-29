"""GPChart Library

@author cbjazz
"""
import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

from gpchart import GpdbChart
from gpchart import OPT_BAR_WIDTH

class GpdbBarChart(GpdbChart):
    """
    This class makes bar chart.
    """

    def __init__(self, title, options):
        """
        Parameters
        ----------
        title : str
            Chart title
        options : str
            Style options with json format
        """
        GpdbChart.__init__(self, title, options)

    def _merge_legend(self, x, y, legends):
        """ This merges all legend into dataframe with same index.

        Parameters
        ----------
        x : None
            x axis data
        y : list
            y axis data
        legend : list
            legend values

        Return
        ----------
        dataframe: merged dataframe through same 'x' values
        """
        unique_x = np.unique(x)
        unique_legend = np.unique(legends)

        df_merge = pd.DataFrame(
            {
                'X': unique_x
            }
        )

        for legend in unique_legend:
            df = pd.DataFrame (
                {
                    'X' : x[np.where(legends == legend)],
                    'Y_' + legend : y[np.where(legends == legend)]
                }
            )
            df_merge = df_merge.merge(df, how='left', on=['X'])

        return df_merge

    def _get_bar_width(self, x_axis_cnt, legend_cnt):
        """ This calculates bar width.

        Parameters
        ----------
        x_axis_cnt : int
            The number of x values
        legend_cnt : int
            The number of legends

        Return
        ----------
        float: bar width
        """
        if (OPT_BAR_WIDTH in self.option_dict.keys()):
            axes_barwidth = self.option_dict[OPT_BAR_WIDTH]
        else:
            axes_barwidth = 1 / (x_axis_cnt * legend_cnt)

        return axes_barwidth

    def draw_chart(self, x, y, legend, sequence):
        """This draws bar chart.
        Args (x, y, legend and sequence) should  have same length.

        Parameters
        ----------
        x : list
            x axis data.
        y : list
            y axis data
        legend : list
            legend values
        sequence: list, optional
            Legends are sorted by sequence number ascendingly.
        """
        # We use numpy array for futher compatibility.
        x = np.array(x)
        y = np.array(y)
        legend = np.array(legend)
        sequence = np.array(sequence)

        if legend.size != 0:
            u_legend = np.unique(legend)
            u_legend_cnt = len(u_legend)
        else:
            u_legend = np.array([self.title])
            u_legend_cnt = 1

        # Set chart sytle
        self._set_style()
        self._set_mpl_option()
        self._set_cycler(u_legend_cnt)

        self.fig, self.ax = plt.subplots()

        self.ax.set_title(self.title)

        # Set legend sequence
        if sequence.size != 0:
            seq = []
            for i in range(u_legend_cnt):
                seq.append(sequence[np.where(legend == u_legend[i])][0])
            sorted_seq_index = np.argsort(seq)
        else:
            seq = np.arange(u_legend_cnt)
            sorted_seq_index = np.arange(u_legend_cnt)

        df = self._merge_legend(x, y, legend)

        # Set bar width
        axes_barwidth = self._get_bar_width(df.shape[0], u_legend_cnt)

        idx = 0
        for i in sorted_seq_index:
            sub_x = df['X']
            sub_y = df['Y_' + u_legend[i]]

            self.ax.bar(np.array(df.index.tolist()) + (axes_barwidth * idx),
                        sub_y,
                        width=axes_barwidth,
                        label=u_legend[i])
            idx = idx + 1

        self.ax.set_xticks(
            np.array(df.index.tolist()) \
                + (axes_barwidth * u_legend_cnt)/2 \
                - (axes_barwidth/2)
        )

        self.ax.set_xticklabels(df['X'])

        self.ax.legend()

if __name__ == '__main__':
    OPTIONS = '''{
        "style":"fivethirtyeight",
        "figure.figsize": [13.0, 6.0],
        "legend.loc":"upper right",
        "lines.marker":"o",
        "axes.color_pallete": ["#ED553B", "#20639B", "#3CAEA3", "#F6D55C"],
        "axes.color_alpha":0.7
        }'''
    chart = GpdbBarChart('test', OPTIONS)
    chart.draw_chart([1, 2, 3, 4, 5, 1, 2, 3, 4],
                     [1, 2, 3, 4, 5, 6, 4, 2, 6],
                     ['A', 'A', 'A', 'A', 'A', 'B', 'B', 'B', 'B'],
                     [1, 1, 1, 2, 2, 2, 3, 3, 3])
    chart.save_file("bar_chart.png")
