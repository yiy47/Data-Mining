import os
import pandas as pd

# LOAD MOBILE DATA
os.chdir('/home/wxm/Desktop/2019_CANGZHOU/result/processed dataset/')
cangzhou_coded = pd.read_csv('cangzhou_coded.csv')

cangzhou_df = cangzhou_coded
cangzhou_df = cangzhou_df.drop(cangzhou_df.columns[[0]], axis=1) 
cangzhou_df = cangzhou_df[cangzhou_df['month']==1]
cangzhou_df = cangzhou_df[cangzhou_df['pm25'].notnull()]
cangzhou_df['date'] = pd.to_datetime(cangzhou_df[['year', 'month', 'day']])
cangzhou_df['date_hour'] = pd.to_datetime(cangzhou_df.date) + pd.to_timedelta(cangzhou_df.hour, unit='h')


#Take the medians by cell and hour (if they weren't already)
df_1hr = cangzhou_df[['geohash_coded','date_hour','pm25']]
df_1hr.columns = ['geohash_coded','date_hour','conc_1hr']
#Then aggregate over the hour periods for each cell
#We can count the number of hour periods and take the median of the hourly concentrations at the same time
df_expected = df_1hr.groupby(['geohash_coded'])['conc_1hr'].agg([('conc_expected','median'),('count','size')]).reset_index()
#Now filter for grids with at least 100 measurements this month
#Note that I increased the number to 100, we want this to be much higher than the highest N that we will test
#We could repeat this requiring 200 to see if the results are sensitive
df_filtered = df_expected[df_expected['count']>=100]
df_merge = df_1hr.merge(df_filtered,on=['geohash_coded'])

#Define the percentiles and the values of N
pct_list = range(1,100) #every 1 percentile
percentile_str_list = ['n_sub']+["p{0:02}t".format(pct) for pct in pct_list]
n_sub_list = [5,10,15,20,25,30,35]
percentile_list = []

#Bias function
def calc_bias(df,n):
    #calculate subsample for a given n
    df_temp = df.groupby(['geohash_coded']).apply(pd.DataFrame.sample, n=n, replace=True)
    df_temp = df_temp.drop('geohash_coded', 1)
    df_temp = df_temp.reset_index()
    df_temp = df_temp.groupby(['geohash_coded']).median().reset_index() #takes the median of all columns
    #calc the bias for all rows
    df_temp['bias'] = (df_temp['conc_expected']-df_temp['conc_1hr'])/df_temp['conc_1hr']*100
    return df_temp

#Loop over N values
for i,value in enumerate(n_sub_list):
    print(value)
    df_bias = pd.DataFrame() #initialize empty dataframe
    #Loop over many random trials
    for k in range(500): #do 500 random trials for every cell
        df_bias = df_bias.append(calc_bias(df_merge,value)) #append all the trials
    #now calculate percentiles over all cells and trials
    percentile_list.append([value]+[df_bias.bias.quantile(pct/100) for pct in pct_list])



percentile_df = pd.DataFrame(percentile_list,columns=percentile_str_list)
percentile_df.to_excel ('/home/wxm/Desktop/2019_CANGZHOU/code/UNCERTAINTY ANALYSIS/result/sampleuncertainty_2019Jan.xlsx', index =False, header=True)





