# gpdb_chart

GPDB에서 matplotlib를 이용해 쉽게 차트를 생성할 수 있는 library 및 procedure 개발을 목표로 하고 있다. 

Basic Usage: 

* py_basic_plot_chart 
```sql
SELECT home_project.py_basic_plot_chart(X, Y, 'Stock Price', legend, NULL, opt)
FROM (
SELECT string_agg(s_close::text, ',' order by s_date) Y,
	string_agg((s_date - '2017-01-01'::date)::text, ',' order by s_date) X,
	string_agg(code, ',' order by s_date) legend,
	'{
    "figure.figsize": [12.0, 6.0], 
    "legend.loc":"upper right",
    "lines.marker":"o",
    "axes.color_map":"PuOr",
    "axes.color_alpha":0.7
    }' opt
FROM stock.price
WHERE code = '090435.KS'
) as a
```

* py_ma_band_plot_chart 
```sql
SELECT home_project.py_ma_band_plot_chart(X, Y, title, 20, 2.0, opt)
FROM (
SELECT string_agg(s_close::text, ',' order by s_date) Y,
	string_agg((s_date - '2017-01-01'::date)::text, ',' order by s_date) X,
	code title,
	'{
    "style":"bmh", 
    "figure.figsize": [12.0, 6.0], 
    "legend.loc":"upper right",
    "axes.color_pallete":["#173F5F", "#20639B", "#ED553B", "#3CAEA3", "#F6D55C"],
    "axes.color_alpha":0.7,
    "axes.band_color" : "#F6D55C",
    "axes.band_color_alpha" : 0.3
    }' opt
FROM stock.price
WHERE code IN ('000240.KS', '090435.KS')
GROUP BY code
) as a
```

* py_box_plot_chart 
```sql
SELECT home_project.py_box_plot_chart(Y, 
    'Stock Price', 
    legend, 
    NULL,
    1.5,
    opt) chart
FROM (
SELECT string_agg(s_close::text, ',' order by s_date) Y,
    string_agg(code, ',' order by s_date) legend,
    '{
    "style":"bmh", 
    "figure.figsize": [12.0, 6.0], 
    "legend.loc":"upper right",
    "lines.marker":"",
    "axes.color_map":"PuOr",
    "axes.color_alpha":0.7
    }' opt
FROM stock.price
WHERE code IN ('090435.KS', '078520.KS', '095570.KS')
    AND s_date >= '2017-11-01' AND s_date < '2017-12-01'
) as a;
```

* py_bar_plot_chart
```sql
SELECT home_project.py_bar_chart(X, Y, 
    'Stock Price', 
    legend, 
    NULL,
    opt) chart
FROM (
SELECT 
	string_agg((s_date - '2017-01-01'::date)::text, ',' order by s_date) X,
	string_agg(s_close::text, ',' order by s_date) Y,
    string_agg(code, ',' order by s_date) legend,
    '{
    "style":"bmh", 
    "figure.figsize": [13.0, 6.0], 
    "legend.loc":"upper right",
    "lines.marker":"o",
    "axes.color_pallete": ["#ED553B", "#20639B", "#3CAEA3", "#F6D55C"],
    "axes.color_alpha":0.7
    }' opt
FROM stock.price
WHERE code IN ('090435.KS', '078520.KS', '095570.KS')
    AND s_date >= '2017-11-01' AND s_date < '2017-12-01'
) as a;
```

Chart Options:
* Default Options : https://matplotlib.org/tutorials/introductory/customizing.html
* Additional Options : 
    - style
    - axes.color_map
    - axes.color_pallete
    - axes.color_alpha
    - axes.band_color : in band chart
    - axes.band_color_alpha : in band chart
    - axes.bar_width : in bar chart
