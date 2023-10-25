derived_data/all_data.csv: data_clean.R utils.R\
source_data/climbing_statistics.csv\
source_data/Rainier_Weather.csv
	Rscript data_clean.R
	
figures/log_popular_routes.png: popular_routes.R derived_data/all_data.csv\
utils.R
	Rscript popular_routes.R
	
figures/hiker_vs_success.png: hiker_vs_success.R derived_data/all_data.csv\
utils.R
	Rscript hiker_vs_success.R