import pandas as pd
import os

# load mobile data
os.chdir('/home/wxm/Desktop/2019_CANGZHOU/result/processed dataset/')
cangzhou_coded = pd.read_csv('cangzhou_coded.csv')

# using data collected in January,2019 as an example
cangzhou_df = cangzhou_coded
cangzhou_df = cangzhou_df.drop(cangzhou_df.columns[[0]], axis=1) 
cangzhou_df = cangzhou_df[cangzhou_df['month']==1]
cangzhou_df['date'] = pd.to_datetime(cangzhou_df[['year', 'month', 'day']])
cangzhou_df['date_hour'] = pd.to_datetime(cangzhou_df.date) + pd.to_timedelta(cangzhou_df.hour, unit='h')

# delete rows with nan values
cangzhou_df = cangzhou_df[cangzhou_df['pm25'].notnull()]
df_0 = cangzhou_df[['geohash_coded','date_hour','pm25']]
df_1 = df_0.groupby(['geohash_coded'])['pm25'].agg([('median','median'),('pass_count','size')]).reset_index()
df_1 = df_1[df_1['pass_count']>=5]

def get_confidence(thresh, df, n, med):
    distrib = df[df['n_sub']==n]
    pct_diff = np.array([distrib['p{0:02}t'.format(a)].iloc[0] for a in range(1,100)])
    x = pct_diff/100*med+med
    y = 1-np.array(range(1,100))/100
    c = np.interp(thresh,x,y)
    return c

# load sampling uncertainty distributions
os.chdir('/home/wxm/Desktop/2019_CANGZHOU/code/UNCERTAINTY ANALYSIS/result')
df_uncertainty = pd.read_excel('sampleuncertainty_2019Jan.xlsx')
threshold = 51
confidence = []
for i,row in df_1.iterrows():
    n = min(int(row['pass_count']/5)*5,35)
    med = row['median']
    confidence.append(get_confidence(threshold,df_uncertainty,n,med))


# export results
df_1['confidence'] = confidence
df_1.to_excel ('/home/wxm/Desktop/2019_CANGZHOU/code/UNCERTAINTY ANALYSIS/result/heweiqu_exceeds_threshold_confidence.xlsx', index =False, header=True)

