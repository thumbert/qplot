# QPlot: a command line utility for plotting data

QPlot (quick-plot) creates nice looking html charts from 
various input data using the plotting library [Plotly](https://plotly.com/javascript/). 

## Input data

Input data can be either in CSV format or a JSON array of objects.  If the first 
character of the input is `[` then the input format is assumed to be JSON.  

### CSV input

Input data is assumed to be comma-separated rows of data with the first line 
as the header.  The first column is the x-axis data, and the remaining columns 
are variables plotted on the y-axis. 

```
cat data.csv | qplot --mode=markers --type=scatter --config='{"height": 800}'  
```

A typical use would be to export the CSV data from a database and then send it to `qplot`
```
duckdb -csv -c "
ATTACH '~/dalmp.duckdb' AS prices;
SELECT * FROM prices.da_lmp
PIVOT (
    min(lmp),
    FOR ptid IN (4000, 4001)
    GROUP BY hour_beginning    
)
WHERE hour_beginning >= '2025-07-14'
AND hour_beginning < '2025-07-15'
ORDER BY hour_beginning;
" | qplot
```

### JSON input

```
cat data.json | qplot 
```

Allowing JSON input opens the door for using `curl` to access API points + `jq` to 
manipulate the resulting JSON payload and then `qplot` for the visualization.   

```
curl 'http://localhost:8111/isone/dalmp/hourly/start/2025-01-01/end/2025-07-14?ptids=4000&components=lmp' \
| jq "[.[] | {hour_beginning, price}]" \
| qplot
```


## Usage

Check the help for a full list of options.
```
qplot --help
```


## Additional information

Release a binary: 
```
dart compile exe bin/qplot.dart -o ~/.local/bin/qplot
```