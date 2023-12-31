PHONY: clean

clean:
	rm -rf derived_data/
	rm -rf figures/
	rm -rf MtRainierProject.html
	#rm -rf derived_data/all_data.csv
	#rm -rf figures/log_popular_routes.png
	#rm -rf figures/hiker_vs_success.png
	#rm -rf figures/pca_quarter.png
	#rm -rf figures/pca_temp.png
	#rm -rf figures/pc1_and_temp.png
	
	
derived_data/all_data.csv: data_clean.R utils.R\
source_data/climbing_statistics.csv\
source_data/Rainier_Weather.csv
	Rscript data_clean.R
	
figures/log_popular_routes.png: popular_routes.R derived_data/all_data.csv\
utils.R
	Rscript popular_routes.R
	
figures/popular_routes.png: popular_routes.R derived_data/all_data.csv\
utils.R
	Rscript popular_routes.R
	
figures/hiker_vs_success.png: hiker_vs_success.R derived_data/all_data.csv\
utils.R
	Rscript hiker_vs_success.R
	
figures/pca_quarter.png: PCAanalysisplots.R derived_data/all_data.csv\
utils.R
	Rscript PCAanalysisplots.R
	
figures/pca_temp.png: PCAanalysisplots.R derived_data/all_data.csv\
utils.R
	Rscript PCAanalysisplots.R

figures/pc1_and_temp.png: PCAanalysisplots.R derived_data/all_data.csv\
utils.R
	Rscript PCAanalysisplots.R
	
derived_data/lasso_coefs.csv: lassomodel.R derived_data/all_data.csv\
utils.R
	Rscript lassomodel.R

figures/raster.png: lassomodel.R derived_data/all_data.csv\
utils.R
	Rscript lassomodel.R

derived_data/pred_tbl_linearmod.csv:lassomodel.R derived_data/all_data.csv\
utils.R
	Rscript lassomodel.R

derived_data/pred_tbl_boostmod.csv:boostmodel.R derived_data/all_data.csv\
utils.R
	Rscript boostmodel.R
	
MtRainierProject.html: MtRainierProject.Rmd figures/pca_quarter.png\
figures/popular_routes.png figures/pc1_and_temp.png figures/hiker_vs_success.png\
figures/pca_temp.png derived_data/lasso_coefs.csv derived_data/pred_tbl_boostmod.csv\
derived_data/pred_tbl_linearmod.csv figures/raster.png
	Rscript -e 'rmarkdown::render("MtRainierProject.Rmd")'	
	