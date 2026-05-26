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

One series:
```bash
curl 'http://localhost:8111/isone/prices/da/hourly/start/2025-01-01/end/2025-01-03?ptids=4000&components=lmp' \
| jq "[.[] | {hour_beginning,price}]" \
| qplot
```

Multiple series:
```bash
curl 'http://localhost:8111/isone/prices/da/hourly/start/2025-01-01/end/2025-01-03?ptids=4000,4008&components=lmp' \
| jq "[.[] | {hour_beginning,price,ptid}]" \
| qplot --group
```


## Usage

Check the help for a full list of options.
```bash
qplot --help
```

```
QPlot -- create a quick plot from piped input data using Plotly JS.  
See https://github.com/thumbert/qplot for more details.

Flags:
-h, --[no-]help       
-v, --[no-]version    Current qplot version.
    --file            Html file path output.  If not specified, it will open in the current browser.
    --config          Plotly config options as a JSON string.  For example: {"height": 800}.
    --mode            Plot mode. Default is "lines". Other options are "markers", "lines+markers", "text", etc.
                      (defaults to "lines")
    --type            Plot mode. Valid options are "bar", "pie", "box", etc.
                      (defaults to "scatter")
    --input           Input mode for the data.  Only CSV and JSON are supported.  If the input 
                      argument is not specified, QPlot looks at the first character of the input.  
                      If it is a "[", it is assumed to be JSON.  Otherwise, it is assumed to be CSV.
                      
                      CSV input should be comma-separated rows of data with the first line as the
                      header.  The first column is the x-axis data, and the remaining columns are 
                      variables plotted on the y-axis.           
                      
                      JSON input should be a JSON array of objects, where each object has the same
                      keys.  The first key is the x-axis data, and the remaining keys are variables.
                      [csv, json]
    --[no-]group      Group data by the last column.  The data needs to have exactly 3 columns 
                      (x, y, group) for CSV input, or 3 keys for JSON input (x, y, group).
    --skip            Number of lines to skip at the beginning of the input.  Only applies to CSV input.
                      (defaults to "0")
    --[no-]header     Whether the input CSV has a header row.  Only applies to CSV input.
                      (defaults to on)

Example usage:
    echo "date,price
    2023-01-01,100
    2023-01-02,150
    2023-01-03,200
    2023-01-04,175
    2023-01-05,225
    " | qplot
  
    cat data.csv | qplot --mode=markers --type=scatter --config='{"height": 800}'  
```


## Additional information

Release a binary: 
```bash
dart compile exe bin/qplot.dart -o ~/.local/bin/qplot
```