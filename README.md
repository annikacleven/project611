Hi, this is my 611 Data Science Project. More to come.\

### What does it take to summit Mt. Rainier?

This project analyzes the trends and statistics related with hikers' success and attempts in 2014 and 2015 at summitting Mt. Rainier. We predict that there are many weather factors that impact the hiker's hiking as well as the amount of hikers on the expedition.

At this point in the project, I have done some data exploration to see what the most popular route hikers have used. I have also analyzed the success of the hikers by the day of the year and separated that by the yeear (2014 vs 2015). Also, included in this plot I show the number of hikers that attempted and the number of hikers that successfully summitted.

### Getting Started

    docker build . --build-arg USER_ID=$(id -u) -t project611

And then start an RStudio by typing:

    docker run --rm -v $(pwd):/home/rstudio/work -v /home/users/arcleven/.ssh:/home/rstudio/.ssh -v ~/.git:/home/rstudio/.git -p 8787:8787 -it project611

Once the Rstudio is running connect to it by visiting <https://localhost:8787> in your browser.

To build the final report, visit the terminal in RStudio and type (Ensure sure that you are in the work directory before running the make commands. You can do this by typing : cd work)

    make derived_data/all_data.csv
    make figures/log_popular_routes.png
    make figures/hiker_vs_success.png
