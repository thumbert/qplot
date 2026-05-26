
## Version 0.2.0 (2026-05-26)
- Support --group flag which allows you to specify if observations get 
  grouped into traces.  It's a convenient feature because the data in 
  the database is usually stored in a long format.  

## Version 0.1.4 (2026-02-20)
- Update Plotly to 3.3.1
- Upgrade csv package to 7.1.0
- Add new option flag header to qplot for CSV files

## Version 0.1.3 (2025-09-26)
- Run the Windows process in shell. 
- Make the process sync
- Don't require the x axis data to be a List<String>.  This won't allow you to 
  do scatter plots for two numeric variables.  

## Version 0.1.2 (2025-09-07)
- Deal with NULLs in the input data.  
- Make sure the `skip` argument is an integer.

## Version 0.1.1 (2025-07-21)
- Initial version.  Improved docs

