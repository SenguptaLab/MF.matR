library(reshape2)
library(ggplot2)
library(stats)
library(dplyr)
library(boot)
library(splines)
library(scales)
library(tcltk)
library(devtools)
install('~/GitHub/wormTracker/R_packages/MF.matR')
library(MF.matR)



# import - process data ---------------------------------------------------


tot.mat<-beh_merge_all(400) # enter # frames to bin
tot.mat<-fix_reversals(tot.mat)
bounds<-c(0, -5, -11, -16)

tot.mat.enter<-norm_beh_enter(tot.mat)
tot.mat.exit<-norm_beh_exit(tot.mat)


# aggregate - calculate mean by groupings ---------------------------------


# calculate mean for each worm by time bin and norm.y
norm_timbin_beh_exit<-aggregate(cbind(Pir, For, Rev, Curve) ~ genotype + norm.y + bin + condition + wormID, data = tot.mat.exit, FUN=mean)
norm_timbin_beh_enter<-aggregate(cbind(Pir, For, Rev, Curve) ~ genotype + norm.y + bin + condition + wormID, data = tot.mat.enter, FUN=mean)


# plot_exit ---------------------------------------------------------------


plot1<-ggplot(norm_timbin_beh_exit, aes(x=norm.y)) +
  annotate("rect", 0,0,-2.5,-0,0,1, fill="lightblue", alpha=0.3) +
  geom_smooth(aes(y=Pir, linetype=condition), method = loess, level=0.99, alpha=0.15, colour="blue") +
  geom_smooth(aes(y=Rev, linetype=condition), method = loess, level=0.99, alpha=0.15,colour="red") +
  geom_smooth(aes(y=Curve, linetype=condition),  method = loess, level=0.99, alpha=0.15,colour="orange") +
  geom_smooth(aes(y=For, linetype=condition),  method = loess, level=0.99, alpha=0.15,colour="green") +
  #geom_density(aes(linetype=condition), data=tot.mat.exit) +
  coord_cartesian(ylim=c(0, 1)) +
  facet_grid(genotype~.) +
  theme_my
plot1


# plot enter --------------------------------------------------------------


plot2<-ggplot(norm_timbin_beh_enter, aes(x=norm.y)) +
  annotate("rect", 0,0,2.5,-0,0,1, fill="lightblue", alpha=0.3) +
  geom_smooth(aes(y=Pir, linetype=condition), method = loess, level=0.99, alpha=0.15, colour="blue") +
  geom_smooth(aes(y=Rev, linetype=condition), method = loess, level=0.99, alpha=0.15,colour="red") +
  geom_smooth(aes(y=Curve, linetype=condition),  method = loess, level=0.99, alpha=0.15,colour="orange") +
  geom_smooth(aes(y=For, linetype=condition),  method = loess, level=0.99, alpha=0.15,colour="green") +
  #geom_density(aes(linetype=condition), data=tot.mat.enter) +
  coord_cartesian(ylim=c(0, 1)) +
  facet_grid(genotype~.) +
  theme_my
plot2



# sanity check ------------------------------------------------------------
sanity<-ggplot(tot.mat.enter, aes(x=norm.y)) +
  geom_density(aes(linetype=condition)) +
  theme_my
sanity

sanity2<-ggplot(tot.mat.exit, aes(x=norm.y)) +
  geom_density(aes(linetype=condition)) +
  theme_my
sanity2

