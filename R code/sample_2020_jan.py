#!/usr/bin/env python
# coding: utf-8

# In[1]:


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


# # 1. Data Preprocessing

# In[2]:


os.getcwd()
os.chdir('/Users/yaoyi/Desktop/sample_test/jan_2020')
extension = 'csv'
all_filenames = [i for i in glob.glob('*.{}'.format(extension))]
combined_csv = pd.concat([pd.read_csv(f) for f in all_filenames])
print(combined_csv.head())


# In[3]:


# define function to remove chinese characters
def cleantxt(raw):
    fil = re.compile(u'[^0-9a-zA-Z\-.，,。？“”]+', re.UNICODE)
    return fil.sub(' ', raw) 


# In[4]:


cangzhou = combined_csv
test = cangzhou['car_no'].apply(lambda x: cleantxt(x))
cangzhou['license_num'] = test
cangzhou.head()


# In[5]:


cangzhou_df = cangzhou
cangzhou_df['Timestamp'] = pd.to_datetime(cangzhou_df['time'])
cangzhou_df['hour'] = pd.DatetimeIndex(cangzhou_df['Timestamp']).hour
cangzhou_df['day'] = pd.DatetimeIndex(cangzhou_df['Timestamp']).day
cangzhou_df['month'] = pd.DatetimeIndex(cangzhou_df['Timestamp']).month
cangzhou_df['year'] = pd.DatetimeIndex(cangzhou_df['Timestamp']).year


# In[6]:


print('number of taxis in Jan,2020 is', len(list(set(cangzhou_df['license_num'].tolist()))))


# In[7]:


print('number of records in Jan, 2020 is ', cangzhou_df.shape[0])


# In[8]:


cangzhou_df = cangzhou_df.drop(cangzhou_df.columns[[0, 1, 6, 7, 8]], axis=1)


# In[9]:


# geohash coded, precision = 7
def Geohash_Coding(data):
    return geohash2.encode(data['lat'],data['lng'],7)

cangzhou_df['geohash_coded'] = cangzhou_df.apply(Geohash_Coding, axis=1)


# In[10]:


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


# In[11]:


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


# In[12]:


cangzhou_coded = cangzhou_df.loc[cangzhou_df['geohash_coded'].isin(heweiqu_geohash_coded)]


# In[13]:


print('number of records in Jan, 2020 in Heweiqu is ', cangzhou_coded.shape[0])
print('number of taxis in Jan,2020 in Heweiqu is', len(list(set(cangzhou_coded['license_num'].tolist()))))
print(6728346-6327741)
print('number of geohash grids in heweiqu is ', len(list(set(cangzhou_coded['geohash_coded'].tolist()))))


# In[14]:


6891/19367


# In[15]:


df_taxi = cangzhou_coded.groupby(['year','month','day'])['license_num'].nunique().reset_index(name='count')
df_taxi['date'] = pd.to_datetime(df_taxi[['year', 'month', 'day']])


# In[16]:


plt.plot(df_taxi['date'],df_taxi['count'])
# plt.xticks(np.arange(idx1, idx2, 10), time_label, fontsize=10)
plt.xticks(rotation=90)
plt.ylabel('Number of Taxis')
plt.title('Number of Taxis in Each Day in Jan, 2020')
plt.show()


# In[17]:


# df_taxi['count'].describe()


# # 2. Subset dataset (data available at least in 3 hours per day & 7 consective days)

# In[18]:


geohash_list =  list(set(cangzhou_coded['geohash_coded'].tolist()))
print('number of unique geohash grids in Jan 2020 is ',len(geohash_list))


# In[19]:


df_1 = cangzhou_coded.groupby(['geohash_coded','year','month','day'])['hour'].nunique().reset_index(name='count')


# In[20]:


df_2 = df_1[df_1['count']>=3]


# In[21]:


print('number of geohash grids with data available at least in 3 hours in one day ', len(list(set(df_2['geohash_coded'].tolist()))))


# In[22]:


df_2['date'] = pd.to_datetime(df_2[['year', 'month', 'day']])


# In[23]:


df_3 = df_2.groupby(['geohash_coded'])['date'].nunique().reset_index(name='count')


# In[24]:


sns.distplot( a=df_3["count"], hist=True, kde=False, rug=False )
plt.xlabel('Number of Days (with data available at least in 3 hours per day) in Jan, 2020')
plt.ylabel('Number of Geohash Grids')
plt.title('Historgram of Number of Geohash Grids in Jan, 2020')


# In[25]:


df_4 = df_3[df_3['count']>=7]
df_4 = df_4.sort_values(by = 'count',axis = 0,ascending = False)


# In[26]:


def getBetweenDay(begin_date,end_date):
  date_list = []
  begin_date = datetime.datetime.strptime(begin_date, "%Y-%m-%d")
  end_date = datetime.datetime.strptime(end_date,'%Y-%m-%d')
  while begin_date <= end_date:
    date_str = begin_date.strftime("%Y-%m-%d")
    date_list.append(date_str)
    begin_date += datetime.timedelta(days=1)
  return date_list


# In[27]:


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
    


# In[33]:


df_trans = df_temp.transpose()


# In[34]:


df_max_days = df_temp.describe()
df_max_days_trans = df_max_days.transpose()
df_max_days_trans.head()


# In[35]:


sns.distplot( a=df_max_days_trans["max"], hist=True, kde=False, rug=False )
plt.xlabel('Maximum Number of Days for Each Grid (with data available in X Consecutive Days) in Jan, 2020')
plt.ylabel('Number of Geohash Grids')
plt.title('Historgram of Number of Geohash Grids in Jan, 2020')


# In[36]:


df_max_days_trans = df_max_days_trans[df_max_days_trans['max']>=7]


# In[168]:


df_all_target.head()


# In[ ]:





# # 3. Calculate PM2.5 concentration for each grid

# In[37]:


cangzhou_copy = cangzhou_coded
cangzhou_copy = cangzhou_copy.set_index('geohash_coded')


# In[38]:


cangzhou_subset = cangzhou_copy[cangzhou_copy.index.isin(df_max_days_trans.index)]


# In[39]:


cangzhou_subset = cangzhou_subset.reset_index()
print(len(list(set(cangzhou_subset['geohash_coded'].tolist()))))


# In[40]:


# a.取每天每个小时每辆车测量值的平均值代表该辆车在该小时的测量浓度
df_pm25_0 = cangzhou_subset.groupby(['geohash_coded','year','month','day','hour','license_num'])['pm25'].mean().reset_index(name='mean_pm25')

# b.取每天各小时所得测量浓度的中位值分别表示目标网格在N个小时内的浓度
df_pm25_1 = df_pm25_0.groupby(['geohash_coded','year','month','day','hour'])['mean_pm25'].median().reset_index(name='median_pm25')

# c.取N个浓度值的中位值表示目标网格在一天中的浓度
df_pm25_2 = df_pm25_1.groupby(['geohash_coded','year','month','day'])['median_pm25'].median().reset_index(name='median_pm25')
df_pm25_2['date'] = pd.to_datetime(df_pm25_2[['year', 'month', 'day']])


# In[41]:


df_pm25_2.head()


# # 4. calculate MA for each geohash grid

# In[43]:


df_days_count = df_temp
df_days_count.head()


# In[44]:


df_pm25_concentration = df_pm25_2
df_pm25_concentration = df_pm25_concentration.loc[:,['date','geohash_coded','median_pm25']]
df_pm25_concentration.head()


# In[45]:


geohash_list_0 = list(set(df_pm25_concentration['geohash_coded'].tolist()))
length_list_0 = len(geohash_list_0)
print(length_list_0)


# In[46]:


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
    


# In[48]:


# test1 = dict_target_ma['wwg1g1n']
# print(test1.head())
# test2 = dict_target_ma['wwg19gr']
# print(test2.head())


# In[49]:


len(dict_target_ma)


# # 5. calculate threshold values for each geohash grid

# In[224]:


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


# In[225]:


lists_all_target = [[] for _ in range(length_list_0)]
geohash_final_list = []
for i in range(length_list_0):
    geohash_id = geohash_list_0[i]
    df_target_ma_temp = cal_warning(geohash_id)
    if(df_target_ma_temp.shape[0]>0):
        geohash_final_list.append(geohash_id)
        lists_all_target[i] = df_target_ma_temp[['warning_'+geohash_id]]['warning_'+geohash_id].tolist()


# In[226]:


df_all_target = pd.DataFrame.from_records(lists_all_target).transpose()
print(len(lists_all_target),len(geohash_final_list))
df_all_target = df_all_target.iloc[:,:1437]
df_all_target.columns = geohash_final_list
print(df_all_target.head())   


# In[227]:


df_all_target.loc['total'] = df_all_target.apply(lambda x: x.sum())
df_all_target.shape[0]
final_result = df_all_target.tail(1)
# import openpyxl


# In[228]:


final_result.to_excel ('/Users/yaoyi/Desktop/final_result.xlsx', index =True, header=True)


# In[229]:


final_result = final_result.transpose()
final_result.columns = ['number of days (target>threshold)']


# # 6. check linear distribution

# In[208]:


df_check_linear = df_pm25_2
df_check_linear_0 = df_check_linear[df_check_linear['geohash_coded'].isin(geohash_final_list)]


# In[209]:


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


# In[210]:


dict_target_r = {}
for geohash_id in (geohash_final_list):
    df_test = cal_r_linear(geohash_id)
    dict_target_r[geohash_id] = df_test


# In[161]:


# day_id = df_test['date'].iloc[i]
# print(day_id)
# print(day_id-datetime.timedelta(days=6))
# dict_target_r['wwg1u62']


# # 7. calculate R squared value (if linear)

# In[211]:


# -----------------------------
# |r|<0.3 不存在线性关系
# 0.3<|r|<0.5  低度线性关系
# 0.5<|r|<0.8  显著线性关系
# |r|>0.8  高度线性关系
# ------------------------------


# In[212]:


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


# In[213]:


dict_final_r2 = {}
for geohash_id in (geohash_final_list):
    df_test = cal_r2(geohash_id)
    dict_final_r2[geohash_id] = df_test
  


# In[214]:


print(len(dict_target_r),len(dict_final_r2))


# In[231]:


final_result = final_result.reset_index()
final_result.head()


# In[251]:


r_count_list = []
r2_count_list = []
exceed_threshold = []
# geohash_result = final_result['index'].tolist()
# print(length_result)


# In[252]:


for index in geohash_result:
    df_test = dict_final_r2[index]
    count_exceed = sum(df_test['warning_'+index].tolist())
    exceed_threshold.append(count_exceed)
    r_count_temp = df_test[df_test['r_linear']>0.8].shape[0]
    r_count_list.append(r_count_temp)
    r2_count_temp = df_test[(df_test['r2']!=0)&(df_test['r2']<0.9)].shape[0]
    r2_count_list.append(r2_count_temp)
    


# In[259]:


d1 = pd.DataFrame()
d1['geohash_id'] = geohash_result
d1['number of days (target>threshold)'] = exceed_threshold
d1['count(r>0.8)'] = r_count_list
d1['count(r2<0.9)'] = r2_count_list


# In[260]:


# final_result['count(r>0.8)']= r_count_list  
# final_result['count(r2<0.9)']= r2_count_list  
# import openpyxl
d1.to_excel ('/Users/yaoyi/Desktop/热点网格结果.xlsx', index =True, header=True)


# # 8. plot heating maps 

# In[61]:


import folium
from folium.plugins import HeatMap
import webbrowser
from folium.plugins import HeatMapWithTime
# https://towardsdatascience.com/data-101s-spatial-visualizations-and-analysis-in-python-with-folium-39730da2adf


# ## 8.1 heatmap - jan, 02

# In[17]:


def generateBaseMap(default_location=[38.317435,116.894054], default_zoom_start=12):
    base_map = folium.Map(location=default_location, control_scale=True, zoom_start=default_zoom_start)
    return base_map


# In[101]:


# df_copy = cangzhou_coded[cangzhou_coded['day']==2]
df_copy = cangzhou_coded
df_copy = df_copy.dropna()


# In[102]:


base_map = generateBaseMap()
HeatMap(data=df_copy[['lat', 'lng', 'pm25']].groupby(['lat', 'lng']).mean().reset_index().values.tolist(), radius=8, max_zoom=13).add_to(base_map)


# In[60]:


os.chdir('/Users/yaoyi/Desktop/sample_test/map')
base_map.save('base_map_jan02.html')
webbrowser.open('base_map_jan02.html')


# ## (NOT WORKING) 8.2 heatmap with hour - jan, 02

# In[62]:


df_hour_list = []
for hour in df_copy.hour.sort_values().unique():
    df_hour_list.append(df_copy.loc[df_copy.hour == hour, ['lat', 'lng', 'pm25']].groupby(['lat', 'lng']).mean().reset_index().values.tolist())


# In[63]:


base_map = generateBaseMap(default_zoom_start=11)
HeatMapWithTime(df_hour_list, radius=5, gradient={0.2: 'blue', 0.4: 'lime', 0.6: 'orange', 1: 'red'}, min_opacity=0.5, max_opacity=0.8, use_local_extrema=True).add_to(base_map)


# In[64]:


os.chdir('/Users/yaoyi/Desktop/sample_test/map')
base_map.save('base_map_hour_jan02.html')
webbrowser.open('base_map_hour_jan02.html')


# # 9. Contour map

# In[17]:


import folium
import branca
from folium import plugins
from scipy.interpolate import griddata
import geojsoncontour
import scipy as sp
import scipy.ndimage
import webbrowser
get_ipython().run_line_magic('matplotlib', 'inline')


# In[14]:


df_copy = cangzhou_coded[['lat','lng','pm25']]
df_copy = df_copy.dropna()

# Setup minimum and maximum values for the contour lines
vmin = df_copy['pm25'].min() 
vmax = df_copy['pm25'].max()

# Setup colormap
colors = ['green','darkgreen','blue','royalblue', 'navy','pink',  'mediumpurple',  'darkorchid',  'plum',  'm', 'mediumvioletred', 'palevioletred', 'crimson',
         'magenta','pink','red','yellow','orange', 'brown']
levels = len(colors)
cm     = branca.colormap.LinearColormap(colors, vmin=vmin, vmax=vmax).to_step(levels)

# Convertion from dataframe to array
x = np.asarray(df_copy.lng.tolist())
y = np.asarray(df_copy.lat.tolist())
z = np.asarray(df_copy.pm25.tolist()) 

# Make a grid
x_arr          = np.linspace(np.min(x), np.max(x), 500)
y_arr          = np.linspace(np.min(y), np.max(y), 500)
x_mesh, y_mesh = np.meshgrid(x_arr, y_arr)

# Grid the elevation
z_mesh = griddata((x, y), z, (x_mesh, y_mesh), method='linear')
 
# Use Gaussian filter to smoothen the contour
sigma = [5, 5]
z_mesh = sp.ndimage.filters.gaussian_filter(z_mesh, sigma, mode='constant')
 
# Create the contour
contourf = plt.contourf(x_mesh, y_mesh, z_mesh, levels, alpha=0.5, colors=colors, linestyles='None', vmin=vmin, vmax=vmax)


# In[15]:


# Convert matplotlib contourf to geojson
geojson = geojsoncontour.contourf_to_geojson(
    contourf=contourf,
    min_angle_deg=3.0,
    ndigits=5,
    stroke_width=1,
    fill_opacity=0.1)

# Set up the map placeholdder
geomap1 = folium.Map([38.317435,116.894054], zoom_start=12, tiles="OpenStreetMap")

# Plot the contour on Folium map
folium.GeoJson(
    geojson,
    style_function=lambda x: {
        'color':     x['properties']['stroke'],
        'weight':    x['properties']['stroke-width'],
        'fillColor': x['properties']['fill'],
        'opacity':   0.5,
    }).add_to(geomap1)
 
# Add the colormap to the folium map for legend
cm.caption = 'Elevation'
geomap1.add_child(cm)
 
# Add the legend to the map
plugins.Fullscreen(position='topright', force_separate_button=True).add_to(geomap1)
# geomap1


# In[18]:


os.chdir('/Users/yaoyi/Desktop/sample_test/map')
geomap1.save('contourMap_jan.html')
webbrowser.open('contourMap_jan.html')


# In[96]:


import xlrd
import json
os.chdir('/Users/yaoyi/Desktop')
df_result = pd.read_excel('热点网格结果.xlsx')


# In[97]:


df_result = df_result.loc[df_result['count(r2<0.9)'] > 0]


# In[103]:


# convertor_1 = geohashlite.GeoJsonHasher()
# convertor_1.geohash_codes = df_result['geohash_id'].tolist()
# convertor_1.decode_geohash(multipolygon=True)
# jsonfile1 = convertor_1.geojson
# jsonfile1 = json.dumps(jsonfile1)
# file = open('jsonfile1.geojson','w')
# file.write(jsonfile1)
# file.close()

# add grids covered layer
def style_grid(feature):
    return{'fillOpacity': 1, 'weight':1, 'fillcolor': '#cc0000', 'color': '#cc0000'}
grid_covered = folium.GeoJson(data=jsonfile1, style_function=style_grid)
grid_covered.add_to(base_map)


# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[456]:


geohash_id = 'wwg1g1n'
linear_dis = [0]
df_check_linear = cal_warning(geohash_id)
# cangzhou_copy_0 = cangzhou_coded
# cangzhou_copy_0['date'] = pd.to_datetime(cangzhou_copy_0[['year', 'month', 'day']])
# cangzhou_copy_1 = df_neighbor_scat_0.groupby(['geohash_coded','year','month','day','hour','license_num'])['pm25'].mean().reset_index(name='pm25')
# cangzhou_copy_2 = cangzhou_copy_1.groupby(['geohash_coded','year','month','day','hour'])['pm25'].median().reset_index(name='pm25')
# cangzhou_copy_3 = cangzhou_copy_2.groupby(['geohash_coded','year','month','day'])['pm25'].median().reset_index(name='pm25')
# cangzhou_copy_3['date'] = pd.to_datetime(cangzhou_copy_3[['year', 'month', 'day']])
# cangzhou_copy_3.head()


# In[476]:


# for i in range(1,31):
#     day_id = df_check_linear['date'].iloc[i]
#     exceed_threshold = df_check_linear['warning_'+geohash_id].loc[day_id]
#     if (exceed_threshold>0):
#         day_id_before = df_check_linear['date'].loc[i-6]
#         df_check_linear_0 = df_check_linear[(df_check_linear['date']<=day_id) & (df_check_linear['date']>=day_id_before)]
#         # dataframe target
#         df_target_scat = df_linear[df_linear['geohash_coded']==geohash_id]
#         df_target_scat = df_target_scat[['date','geohash_coded','pm25']]
#         # dataframe neighbors
#         neighbor_list_temp = geohash.neighbors(geohash_id)
#         df_neighbor_scat_0 = df_linear.loc[df_linear['geohash_coded'].isin(neighbor_list_temp)]
#         df_neighbor_scat = df_neighbor_scat_0.groupby(['date'])['pm25'].mean().reset_index(name='pm25')
#         r,p = stats.pearsonr(df_target_scat['pm25'],df_neighbor_scat_4['pm25'])  # 相关系数和P值
#         linear_dis.append(r)
#     else:
#         linear_dis.append(0)


# In[ ]:





# In[ ]:





# In[473]:


# df_linear = cangzhou_copy_3[(cangzhou_copy_3['date']<=day_id) & (cangzhou_copy_3['date']>=day_id_before)]
# dataframe target
df_target_scat = df_check_linear_0[[geohash_id+'_ma']]
df_target_scat
# df_target_scat = df_target_scat[['date','geohash_coded','pm25']]
# # dataframe neighbors
neighbor_list_temp = geohash.neighbors(geohash_id)
df_neighbor_scat_0 = df_linear.loc[df_linear['geohash_coded'].isin(neighbor_list_temp)]
df_neighbor_scat = df_neighbor_scat_0.groupby(['date'])['pm25'].mean().reset_index(name='pm25')
# stats.pearsonr(df_target_scat['pm25'],df_neighbor_scat_4['pm25'])  # 相关系数和P值


# In[485]:


target_ma_keyList = [*dict_target_ma] 
list(set(target_ma_keyList).intersection(neighbor_list_temp))
    


# In[475]:


df_target_scat


# In[460]:


day_id = df_check_linear['date'].loc[9]
day_id_before = df_check_linear['date'].loc[9-6]


# In[431]:


df_target_scat = cangzhou_coded[cangzhou_coded['geohash_coded']==geohash_id]
df_target_scat['date'] =  pd.to_datetime(df_target_scat[['year', 'month', 'day']])
df_target_scat = df_target_scat[(df_target_scat['date']<=day_id) & (df_target_scat['date']>=day_id_before)]
        


# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:


####################################################################################


# In[411]:


df_all_target.loc['total'] = df_all_target.apply(lambda x: x.sum())
df_all_target.shape[0]
final_result = df_all_target.tail(1)
import openpyxl
final_result.to_excel ('/Users/yaoyi/Desktop/final_result.xlsx', index =True, header=True)


# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:


####################################################################################


# In[353]:


geohash_id = 'wwg441c'
df_target_ma_temp = cal_warning(geohash_id)
df_target_ma_temp = df_target_ma_temp[['warning_'+geohash_id]]['warning_'+geohash_id].tolist()

    


# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[354]:


geohash_id = 'wwg1epu'
neighbors_temp = geohash.neighbors(geohash_id)
print(neighbors_temp)
df_target_ma = dict_target_ma[geohash_id]
target_ma_keyList = [*dict_target_ma] 
intersectionList= list(set(target_ma_keyList).intersection(neighbors_temp))
print(intersectionList)
df_neighbor = pd.DataFrame()
for neighbor_id in intersectionList:
    print(neighbor_id)
    df_neighbor_temp = dict_target_ma[neighbor_id]
    df_neighbor_temp.rename(columns={df_neighbor_temp.columns[1]: neighbor_id, 
                     df_neighbor_temp.columns[2]: neighbor_id+"_pm25", 
                     df_neighbor_temp.columns[3]: neighbor_id+"_ma"}, inplace = True)
    df_neighbor = pd.concat([df_neighbor.reset_index(drop=True), df_neighbor_temp], axis=1)


# In[356]:


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
outcome_list


# In[358]:


ma_lists = [[] for _ in range(len_intersection)]
len(ma_lists)
for i in range(len_intersection):
    neighbor_id = intersectionList[i]
    ma_lists[i] = df_neighbor[[neighbor_id+'_ma']][neighbor_id+'_ma'].tolist()

df_ma_lists = pd.DataFrame.from_records(ma_lists).transpose()
df_ma_lists.columns = intersectionList
df_ma_lists['outcome'] = outcome_list

df_ma_lists['ma_avg'] = df_ma_lists.iloc[:,0:len_intersection].mean(1)*1.15


# In[ ]:





# In[362]:


df_target_ma['neighbor_ma'] = df_ma_lists['ma_avg'] 
print(df_target_ma.head())
warning_list = []
for i in range(31):
    target_ma_temp = df_target_ma[geohash_id+'_ma'].loc[i]
    neighbor_ma_temp = df_target_ma['neighbor_ma'].loc[i]
    if (target_ma_temp>neighbor_ma_temp):
        warning_list.append(1)
    else:
        warning_list.append(0)
        
df_target_ma['warning'] = warning_list


# In[363]:


df_target_ma


# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:


####################################################################################


# In[ ]:





# In[ ]:





# In[183]:


geohash_filtered_0 = list(set(df_pm25_2['geohash_coded'].tolist()))
length_geohash_filtered_0 = len(geohash_filtered_0)


# In[398]:


geohash_temp = geohash_filtered_0[0]
print(geohash_temp)


# In[381]:


df_pm25_temp = df_pm25_2[df_pm25_2['geohash_coded']==geohash_temp]


# In[382]:


df_days_count_temp = df_days_count.loc[:,['date',geohash_temp]] 


# In[383]:


df_pm25_merge_temp = df_days_count_temp.merge(df_pm25_temp, how='left',on=['date'])


# In[384]:


df_pm25_merge_temp = df_pm25_merge_temp.fillna(0)


# In[385]:


col_1 = df_pm25_merge_temp[geohash_temp].tolist()
col_2 = df_pm25_merge_temp['median_pm25'].tolist()


# In[386]:


ma_temp = []
length_col_1 = len(col_1)
# pm25_temp = col_1[0]
# ma_temp.append(pm25_temp)
for i in range(0,length_col_1):
    count_temp = col_1[i]
    if count_temp<7:
        ma_temp.append(0)
    else:
        pm25_temp_0 = []
        for j in range(i-6,i+1):
            pm25_temp_0.append(col_2[j])
        ma = sum(pm25_temp_0)/7
        ma_temp.append(ma)


# In[387]:


df_pm25_merge_temp['ma_pm25(7 days)'] = ma_temp


# In[475]:


df_pm25_merge_temp.head()


# In[ ]:





# In[ ]:





# In[390]:


neighbors_temp = geohash.neighbors(geohash_temp)
print(neighbors_temp)


# In[401]:


df_pm25_neighbors = df_pm25_2
df_pm25_neighbors = df_pm25_neighbors.set_index('geohash_coded')
df_pm25_neighbors_temp = df_pm25_neighbors[df_pm25_neighbors.index.isin(neighbors_temp)]
df_pm25_neighbors_temp = df_pm25_neighbors_temp.reset_index()


# In[413]:


df_pm25_neighbors_temp


# In[402]:


neighbor_geohash_temp = list(set(df_pm25_neighbors_temp['geohash_coded'].tolist()))
print(neighbor_geohash_temp)


# In[410]:


df_days_count_neighbor_temp = df_days_count.loc[:,['date',neighbor_geohash_temp[0]]] 
df_pm25_merge_neighbor_temp = df_days_count_neighbor_temp.merge(df_pm25_neighbors_temp, how='left',on=['date'])
df_pm25_merge_neighbor_temp = df_pm25_merge_neighbor_temp.fillna(0)
neighbor_col_1 = df_pm25_merge_neighbor_temp[neighbor_geohash_temp[0]].tolist()
neighbor_col_2 = df_pm25_merge_neighbor_temp['median_pm25'].tolist()
ma_neighbor_temp = []
length_neighbor_col_1 = len(neighbor_col_1)
for i in range(0,length_neighbor_col_1):
    count_temp = neighbor_col_1[i]
    if count_temp<7:
        ma_neighbor_temp.append(0)
    else:
        pm25_temp_0 = []
        for j in range(i-6,i+1):
            pm25_temp_0.append(neighbor_col_2[j])
        ma = sum(pm25_temp_0)/7
        ma_neighbor_temp.append(ma)


# In[411]:


df_pm25_merge_neighbor_temp['ma_neighbor_pm25(7 days)'] = ma_neighbor_temp


# In[422]:


neighbor_pm25_list = [107.80,122.60,67.40,99.25,51.78,24.08,43.85]
target_pm25_list = [107.08,122.30,69.07,98.64,55.90,22.13,42.53]


# In[426]:


plt.scatter(neighbor_pm25_list,target_pm25_list)
plt.xlabel('pm2.5 - neighbor')
plt.ylabel('pm2.5 - target')
plt.title('scatter plot of PM2.5 between target grid and its neighbor(s)')
plt.show()


# In[427]:


import statsmodels.formula.api as sm
res_df = pd.DataFrame(
    {'target':target_pm25_list ,
     'neighbor': neighbor_pm25_list})
result = sm.ols(formula="target ~ neighbor", data=res_df).fit()
print(result.params)
print(result.summary())


# In[473]:


# # export dataset
# export_1 = cangzhou_coded
# export_1['date'] = pd.to_datetime(export_1[['year', 'month', 'day']])
# export_2 = export_1[export_1['date']<='2020-01-10']
# export_3 = export_2.groupby(['geohash_coded','date','hour','license_num'])['pm25'].mean().reset_index(name='pm25')
# export_4 = export_3.groupby(['geohash_coded','date','hour'])['pm25'].median().reset_index(name='pm25')
# export_5 = export_4.groupby(['geohash_coded','date'])['pm25'].median().reset_index(name='pm25')
# import openpyxl
# export_5.to_excel ('/Users/yaoyi/Desktop/pm25_export.xlsx', index =True, header=True)


# In[ ]:





# In[ ]:




