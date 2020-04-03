import pandas as pd
import os
import glob
import re
import datetime
import geohash2
import geohashlite
from geojson import Polygon
import seaborn as sns
import matplotlib.pyplot as plt
import geohash
from datetime import timedelta
import numpy as np
import scipy.stats as stats
import openpyxl


# # 1. Data Preprocessing
os.getcwd()
os.chdir('/Users/yaoyi/Desktop/sample_test/jan_2020')
extension = 'csv'
all_filenames = [i for i in glob.glob('*.{}'.format(extension))]
combined_csv = pd.concat([pd.read_csv(f) for f in all_filenames])
print(combined_csv.head())

# define function to remove chinese characters
def cleantxt(raw):
    fil = re.compile(u'[^0-9a-zA-Z\-.，,。？“”]+', re.UNICODE)
    return fil.sub(' ', raw) 

cangzhou = combined_csv
test = cangzhou['car_no'].apply(lambda x: cleantxt(x))
cangzhou['license_num'] = test
cangzhou.head()

cangzhou_df = cangzhou
cangzhou_df['Timestamp'] = pd.to_datetime(cangzhou_df['time'])
cangzhou_df['hour'] = pd.DatetimeIndex(cangzhou_df['Timestamp']).hour
cangzhou_df['day'] = pd.DatetimeIndex(cangzhou_df['Timestamp']).day
cangzhou_df['month'] = pd.DatetimeIndex(cangzhou_df['Timestamp']).month
cangzhou_df['year'] = pd.DatetimeIndex(cangzhou_df['Timestamp']).year
cangzhou_df = cangzhou_df.drop(cangzhou_df.columns[[0, 1, 6, 7, 8]], axis=1)

# geohash coded, precision = 7
def Geohash_Coding(data):
    return geohash2.encode(data['lat'],data['lng'],7)

cangzhou_df['geohash_coded'] = cangzhou_df.apply(Geohash_Coding, axis=1)

# heweiqu
geo_heweiqu = [
          [
            116.79630210963774,
            38.41697643074283
          ],
          [
            116.78050926295805,
            38.39975859733149
          ],
          [
            116.76883628932524,
            38.3841513927093
          ],
          [
            116.76196983424711,
            38.367464104296495
          ],
          [
            116.75784996120024,
            38.34484938092236
          ],
          [
            116.74617698756742,
            38.324382354713556
          ],
          [
            116.74686363307524,
            38.29744325006786
          ],
          [
            116.73999717799711,
            38.26294659582095
          ],
          [
            116.77844932643461,
            38.265103116905344
          ],
          [
            116.80797508327055,
            38.25000612494912
          ],
          [
            116.82582786647367,
            38.245152854243734
          ],
          [
            116.84574058620024,
            38.23382729576134
          ],
          [
            116.87320640651274,
            38.22951233325589
          ],
          [
            116.90067222682524,
            38.230591097883135
          ],
          [
            116.93019798366117,
            38.23436664807367
          ],
          [
            116.95011070338774,
            38.23436664807367
          ],
          [
            117.00641563502836,
            38.2467706471517
          ],
          [
            117.00778892604399,
            38.27642380223557
          ],
          [
            117.00916221705961,
            38.292054228359184
          ],
          [
            117.00572898952055,
            38.302293027404446
          ],
          [
            116.99680259791899,
            38.31737915019811
          ],
          [
            116.99130943385649,
            38.342156681461404
          ],
          [
            116.98306968776274,
            38.3561576255589
          ],
          [
            116.97139671412992,
            38.36369547427178
          ],
          [
            116.93981102077055,
            38.36692574059258
          ],
          [
            116.92813804713774,
            38.36584900117075
          ],
          [
            116.90204551784086,
            38.370694202421134
          ],
          [
            116.88625267116117,
            38.386304310859394
          ],
          [
            116.86359336940336,
            38.39975859733149
          ],
          [
            116.83475425807524,
            38.41159629846819
          ],
          [
            116.8052285012393,
            38.41805240912267
          ],
          [
            116.79630210963774,
            38.41697643074283
          ]
]

Polygon(geo_heweiqu)
# geojson to geohash
converter = geohashlite.GeoJsonHasher()
fc = {
    "type": "FeatureCollection",
    "features":[
        {"type": "Feature",
        "geometry":{"type":"Polygon",
                   "coordinates":[[
          [
            116.79630210963774,
            38.41697643074283
          ],
          [
            116.78050926295805,
            38.39975859733149
          ],
          [
            116.76883628932524,
            38.3841513927093
          ],
          [
            116.76196983424711,
            38.367464104296495
          ],
          [
            116.75784996120024,
            38.34484938092236
          ],
          [
            116.74617698756742,
            38.324382354713556
          ],
          [
            116.74686363307524,
            38.29744325006786
          ],
          [
            116.73999717799711,
            38.26294659582095
          ],
          [
            116.77844932643461,
            38.265103116905344
          ],
          [
            116.80797508327055,
            38.25000612494912
          ],
          [
            116.82582786647367,
            38.245152854243734
          ],
          [
            116.84574058620024,
            38.23382729576134
          ],
          [
            116.87320640651274,
            38.22951233325589
          ],
          [
            116.90067222682524,
            38.230591097883135
          ],
          [
            116.93019798366117,
            38.23436664807367
          ],
          [
            116.95011070338774,
            38.23436664807367
          ],
          [
            117.00641563502836,
            38.2467706471517
          ],
          [
            117.00778892604399,
            38.27642380223557
          ],
          [
            117.00916221705961,
            38.292054228359184
          ],
          [
            117.00572898952055,
            38.302293027404446
          ],
          [
            116.99680259791899,
            38.31737915019811
          ],
          [
            116.99130943385649,
            38.342156681461404
          ],
          [
            116.98306968776274,
            38.3561576255589
          ],
          [
            116.97139671412992,
            38.36369547427178
          ],
          [
            116.93981102077055,
            38.36692574059258
          ],
          [
            116.92813804713774,
            38.36584900117075
          ],
          [
            116.90204551784086,
            38.370694202421134
          ],
          [
            116.88625267116117,
            38.386304310859394
          ],
          [
            116.86359336940336,
            38.39975859733149
          ],
          [
            116.83475425807524,
            38.41159629846819
          ],
          [
            116.8052285012393,
            38.41805240912267
          ],
          [
            116.79630210963774,
            38.41697643074283
          ]
                   ]],
                    "properties": {"prop0": "value0"}
                   }}
    ]
}
converter.geojson = fc
heweiqu_geohash_coded = converter.encode_geojson(precision = 7)
print(type(heweiqu_geohash_coded))
print("合围区划分为{}个网格".format(len(set(heweiqu_geohash_coded))))

cangzhou_coded = cangzhou_df.loc[cangzhou_df['geohash_coded'].isin(heweiqu_geohash_coded)]
df_taxi = cangzhou_coded.groupby(['year','month','day'])['license_num'].nunique().reset_index(name='count')
df_taxi['date'] = pd.to_datetime(df_taxi[['year', 'month', 'day']])
plt.plot(df_taxi['date'],df_taxi['count'])
# plt.xticks(np.arange(idx1, idx2, 10), time_label, fontsize=10)
plt.xticks(rotation=90)
plt.ylabel('Number of Taxis')
plt.title('Number of Taxis in Each Day in Jan, 2020')
plt.show()

# # 2. Subset dataset (data available at least in 3 hours per day & 7 consective days)

geohash_list =  list(set(cangzhou_coded['geohash_coded'].tolist()))
df_1 = cangzhou_coded.groupby(['geohash_coded','year','month','day'])['hour'].nunique().reset_index(name='count')
df_2 = df_1[df_1['count']>=3]
df_2['date'] = pd.to_datetime(df_2[['year', 'month', 'day']])
df_3 = df_2.groupby(['geohash_coded'])['date'].nunique().reset_index(name='count')
sns.distplot( a=df_3["count"], hist=True, kde=False, rug=False )
plt.xlabel('Number of Days (with data available at least in 3 hours per day) in Jan, 2020')
plt.ylabel('Number of Geohash Grids')
plt.title('Historgram of Number of Geohash Grids in Jan, 2020')

df_4 = df_3[df_3['count']>=7]
df_4 = df_4.sort_values(by = 'count',axis = 0,ascending = False)

def getBetweenDay(begin_date,end_date):
  date_list = []
  begin_date = datetime.datetime.strptime(begin_date, "%Y-%m-%d")
  end_date = datetime.datetime.strptime(end_date,'%Y-%m-%d')
  while begin_date <= end_date:
    date_str = begin_date.strftime("%Y-%m-%d")
    date_list.append(date_str)
    begin_date += datetime.timedelta(days=1)
  return date_list

geohash_filtered = list(set(df_4['geohash_coded'].tolist()))
geohash_length = len(geohash_filtered)
print(geohash_length)

# create a new dataframe
jan_date_list = getBetweenDay('2020-1-1','2020-1-31')
col_names = ['date']
df_temp = pd.DataFrame(columns = col_names)
df_temp['date'] = jan_date_list
df_temp['date'] = pd.to_datetime(df_temp['date'])

for i in range(geohash_length):
    geohash_temp = geohash_filtered[i]
    df_geohash = df_2[df_2['geohash_coded']==geohash_temp]
    date_list_temp = list(set(df_geohash['date'].tolist()))
    df_temp[geohash_temp] = df_temp['date'].isin(date_list_temp).map({True:1,
                                                     False:0})
    count_origin = df_temp[geohash_temp].tolist()
    length = len(count_origin)
    count_after = []
    count_temp = count_origin[0]
    count_after.append(count_temp)
    for i in range(1,length):
        if count_origin[i]!=0:
            count_temp_0 = count_after[i-1]+1
            count_after.append(count_temp_0)
        else:
            count_after.append(0)
    df_temp[geohash_temp] = count_after
    
df_max_days = df_temp.describe()
df_max_days_trans = df_max_days.transpose()
df_max_days_trans.head()

sns.distplot( a=df_max_days_trans["max"], hist=True, kde=False, rug=False )
plt.xlabel('Maximum Number of Days for Each Grid (with data available in X Consecutive Days) in Jan, 2020')
plt.ylabel('Number of Geohash Grids')
plt.title('Historgram of Number of Geohash Grids in Jan, 2020')

df_max_days_trans = df_max_days_trans[df_max_days_trans['max']>=7]


# # 3. Calculate PM2.5 concentration for each grid
cangzhou_copy = cangzhou_coded
cangzhou_copy = cangzhou_copy.set_index('geohash_coded')
cangzhou_subset = cangzhou_copy[cangzhou_copy.index.isin(df_max_days_trans.index)]
cangzhou_subset = cangzhou_subset.reset_index()
print(len(list(set(cangzhou_subset['geohash_coded'].tolist()))))

# a.取每天每个小时每辆车测量值的平均值代表该辆车在该小时的测量浓度
df_pm25_0 = cangzhou_subset.groupby(['geohash_coded','year','month','day','hour','license_num'])['pm25'].mean().reset_index(name='mean_pm25')

# b.取每天各小时所得测量浓度的中位值分别表示目标网格在N个小时内的浓度
df_pm25_1 = df_pm25_0.groupby(['geohash_coded','year','month','day','hour'])['mean_pm25'].median().reset_index(name='median_pm25')

# c.取N个浓度值的中位值表示目标网格在一天中的浓度
df_pm25_2 = df_pm25_1.groupby(['geohash_coded','year','month','day'])['median_pm25'].median().reset_index(name='median_pm25')
df_pm25_2['date'] = pd.to_datetime(df_pm25_2[['year', 'month', 'day']])

# # 4. calculate MA for each geohash grid
df_days_count = df_temp
df_days_count.head()

df_pm25_concentration = df_pm25_2
df_pm25_concentration = df_pm25_concentration.loc[:,['date','geohash_coded','median_pm25']]
df_pm25_concentration.head()
geohash_list_0 = list(set(df_pm25_concentration['geohash_coded'].tolist()))
length_list_0 = len(geohash_list_0)
print(length_list_0)

dict_target_ma = {}
for geohash_id in geohash_list_0:
    df_pm25_conc_temp = df_pm25_concentration[df_pm25_concentration['geohash_coded']==geohash_id]
    df_pm25_conc_temp = df_pm25_conc_temp.loc[:,['date','median_pm25']]
    df_days_count_temp = df_days_count.loc[:,['date',geohash_id]]
    df_merge_temp = df_days_count_temp.merge(df_pm25_conc_temp, how='left',on=['date'])
    df_merge_temp = df_merge_temp.fillna(0)
    list_count = df_merge_temp[geohash_id].tolist()
    list_pm25 = df_merge_temp['median_pm25'].tolist()
    ma_temp = []
    length_Lcount = len(list_count)
    for j in range(0,length_Lcount):
        count_temp = list_count[j]
        if count_temp<2:
            ma_temp.append(0)
        else:
            pm25_temp = []
            # ma: window = 2
            n = 2
            for z in range(j-n+1,j+1):
                pm25_temp.append(list_pm25[z])
            ma = sum(pm25_temp)/n
            ma_temp.append(ma)
    df_merge_temp[geohash_id+'_ma'] = ma_temp
    dict_target_ma[geohash_id] = df_merge_temp

# # 5. calculate threshold values for each geohash grid

def cal_warning(geohash_id):
    neighbors_temp = geohash.neighbors(geohash_id)
    df_target_ma = dict_target_ma[geohash_id]
#     print(list(df_target_ma.columns.values))
    target_ma_keyList = [*dict_target_ma] 
    intersectionList= list(set(target_ma_keyList).intersection(neighbors_temp))
    if (len(intersectionList)>0): 
        df_neighbor = pd.DataFrame()
        for neighbor_id in intersectionList:
#             print(neighbor_id)
            df_neighbor_temp = dict_target_ma[neighbor_id]
            df_neighbor_temp.rename(columns={df_neighbor_temp.columns[1]: neighbor_id, 
                             df_neighbor_temp.columns[2]: neighbor_id+"_pm25", 
                             df_neighbor_temp.columns[3]: neighbor_id+"_ma"}, inplace = True)
            df_neighbor = pd.concat([df_neighbor.reset_index(drop=True), df_neighbor_temp], axis=1)
        df_neighbor = df_neighbor.loc[:, ~df_neighbor.columns.duplicated()]
        len_intersection = len(intersectionList)
        count_lists = [[] for _ in range(len_intersection)]
        len(count_lists)
        for i in range(len_intersection):
            neighbor_id = intersectionList[i]
            count_lists[i] = df_neighbor[[neighbor_id]][neighbor_id].tolist()
        df_count_lists = pd.DataFrame.from_records(count_lists).transpose()
        df_count_lists['outcome'] = df_count_lists.eq(df_count_lists.iloc[:, 0], axis=0).all(1)
        outcome_list = df_count_lists['outcome'].tolist()
        ma_lists = [[] for _ in range(len_intersection)]
        len(ma_lists)
        for j in range(len_intersection):
            neighbor_id = intersectionList[j]
            ma_lists[j] = df_neighbor[[neighbor_id+'_ma']][neighbor_id+'_ma'].tolist()
        df_ma_lists = pd.DataFrame.from_records(ma_lists).transpose()
        df_ma_lists.columns = intersectionList
        df_ma_lists['outcome'] = outcome_list
        df_ma_lists['ma_avg'] = df_ma_lists.iloc[:,0:len_intersection].mean(1)*1.15
        df_target_ma['threshold'] = df_ma_lists['ma_avg'] 
#         print(list(df_target_ma.columns.values))
        warning_list = []
        for z in range(31):
            target_ma_temp = df_target_ma[geohash_id+'_ma'].loc[z]
            neighbor_ma_temp = df_target_ma['threshold'].loc[z]
            if (target_ma_temp>neighbor_ma_temp):
                warning_list.append(1)
            else:
                warning_list.append(0)
        df_target_ma['warning_'+geohash_id] = warning_list
#         return df_target_ma
    else:
        df_target_ma = pd.DataFrame()
    return df_target_ma
#     dict_warning_result[geohash_id] = df_target_ma

lists_all_target = [[] for _ in range(length_list_0)]
geohash_final_list = []
for i in range(length_list_0):
    geohash_id = geohash_list_0[i]
    df_target_ma_temp = cal_warning(geohash_id)
    if(df_target_ma_temp.shape[0]>0):
        geohash_final_list.append(geohash_id)
        lists_all_target[i] = df_target_ma_temp[['warning_'+geohash_id]]['warning_'+geohash_id].tolist()

df_all_target = pd.DataFrame.from_records(lists_all_target).transpose()
print(len(lists_all_target),len(geohash_final_list))
df_all_target = df_all_target.iloc[:,:1437]
df_all_target.columns = geohash_final_list
print(df_all_target.head())   


df_all_target.loc['total'] = df_all_target.apply(lambda x: x.sum())
df_all_target.shape[0]
final_result = df_all_target.tail(1)


final_result.to_excel ('/Users/yaoyi/Desktop/final_result.xlsx', index =True, header=True)
final_result = final_result.transpose()
final_result.columns = ['number of days (target>threshold)']


# # 6. check linear distribution
df_check_linear = df_pm25_2
df_check_linear_0 = df_check_linear[df_check_linear['geohash_coded'].isin(geohash_final_list)]
def cal_r_linear(geohash_id):
    df_test = cal_warning(geohash_id)
    r_list = []
    for i in range(31):
        day_id = df_test['date'].iloc[i]
        exceed_threshold = df_test['warning_'+geohash_id].loc[i]
        if(exceed_threshold==1):
            day_id_before = day_id-datetime.timedelta(days=6)
            df_check_linear_1 = df_check_linear_0[(df_check_linear_0['date']<=day_id) & (df_check_linear_0['date']>=day_id_before)]
            # dataframe target
            df_test_target = df_check_linear_1[df_check_linear_1['geohash_coded']==geohash_id]
#             print(df_test_target['date'].tolist())
            # dataframe neighbor
            neighbor_list_temp = geohash.neighbors(geohash_id)
            df_test_neighbor = df_check_linear_1.loc[df_check_linear_1['geohash_coded'].isin(neighbor_list_temp)]
            df_test_neighbor_0 = df_test_neighbor.groupby(['date'])['median_pm25'].mean().reset_index(name='pm25_neighbor')
            df_test_merge = df_test_target.merge(df_test_neighbor_0,on=['date'])
#             print(df_test_neighbor_0['date'].tolist())
            r,p = stats.pearsonr(df_test_merge['median_pm25'],df_test_merge['pm25_neighbor'])  # 相关系数和P值
            r_list.append(r)
        else:
            r_list.append(0)
    df_test['r_linear'] = r_list
    return df_test

dict_target_r = {}
for geohash_id in (geohash_final_list):
    df_test = cal_r_linear(geohash_id)
    dict_target_r[geohash_id] = df_test


# # 7. calculate R squared value (if linear)
# -----------------------------
# |r|<0.3 不存在线性关系
# 0.3<|r|<0.5  低度线性关系
# 0.5<|r|<0.8  显著线性关系
# |r|>0.8  高度线性关系
# ------------------------------
import statsmodels.formula.api as sm

def cal_r2(geohash_id):
    df_test = dict_target_r[geohash_id]
    r2_list=[]
    for i in range(31):
        r_temp = df_test['r_linear'].iloc[i]
        if(r_temp>0.8):
            day_id = df_test['date'].iloc[i]
            day_id_before = day_id-datetime.timedelta(days=6)
            df_check_linear_1 = df_check_linear_0[(df_check_linear_0['date']<=day_id) & (df_check_linear_0['date']>=day_id_before)]
            df_test_target = df_check_linear_1[df_check_linear_1['geohash_coded']==geohash_id]
            neighbor_list_temp = geohash.neighbors(geohash_id)
            df_test_neighbor = df_check_linear_1.loc[df_check_linear_1['geohash_coded'].isin(neighbor_list_temp)]
            df_test_neighbor_0 = df_test_neighbor.groupby(['date'])['median_pm25'].mean().reset_index(name='pm25_neighbor')
            df_test_merge = df_test_target.merge(df_test_neighbor_0,on=['date'])
    #         print(df_test_merge)
            result = sm.ols(formula="median_pm25 ~ pm25_neighbor", data=df_test_merge).fit()
    #         print(result.summary())
            r2_list.append(result.rsquared)
        else:
            r2_list.append(0)
    df_test['r2'] = r2_list
    return df_test
dict_final_r2 = {}
for geohash_id in (geohash_final_list):
    df_test = cal_r2(geohash_id)
    dict_final_r2[geohash_id] = df_test

final_result = final_result.reset_index()
r_count_list = []
r2_count_list = []
exceed_threshold = []

for index in geohash_result:
    df_test = dict_final_r2[index]
    count_exceed = sum(df_test['warning_'+index].tolist())
    exceed_threshold.append(count_exceed)
    r_count_temp = df_test[df_test['r_linear']>0.8].shape[0]
    r_count_list.append(r_count_temp)
    r2_count_temp = df_test[(df_test['r2']!=0)&(df_test['r2']<0.9)].shape[0]
    r2_count_list.append(r2_count_temp)

d1 = pd.DataFrame()
d1['geohash_id'] = geohash_result
d1['number of days (target>threshold)'] = exceed_threshold
d1['count(r>0.8)'] = r_count_list
d1['count(r2<0.9)'] = r2_count_list
d1.to_excel ('/Users/yaoyi/Desktop/热点网格结果.xlsx', index =True, header=True)
