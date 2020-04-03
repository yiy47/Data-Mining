#!/usr/bin/env python
# coding: utf-8

# In[ ]:


# https://blog.csdn.net/liyantianmin/article/details/83042770


# In[1]:


import pandas as pd
import os
import geohash2
from polygon_geohasher.polygon_geohasher import geohash_to_polygon
from geopandas import GeoDataFrame
import branca
import branca.colormap as cm
import math
import folium


# In[2]:


# load mobile data
os.chdir('/home/wxm/Desktop/2019_CANGZHOU/result/processed dataset/')
cangzhou_coded = pd.read_csv('cangzhou_coded.csv')


# In[3]:


# using data collected in January,2019 as an example
cangzhou_df = cangzhou_coded
cangzhou_df = cangzhou_df.drop(cangzhou_df.columns[[0]], axis=1) 
cangzhou_df = cangzhou_df[cangzhou_df['month']==1]
cangzhou_df['date'] = pd.to_datetime(cangzhou_df[['year', 'month', 'day']])
cangzhou_df['date_hour'] = pd.to_datetime(cangzhou_df.date) + pd.to_timedelta(cangzhou_df.hour, unit='h')


# In[6]:


# delete rows with nan values
cangzhou_df = cangzhou_df[cangzhou_df['pm25'].notnull()]
df_0 = cangzhou_df[['geohash_coded','date_hour','pm25']]
df_1 = df_0.groupby(['geohash_coded'])['pm25'].agg([('median','median'),('pass_count','size')]).reset_index()
df_1 = df_1[df_1['pass_count']>=5]


# In[7]:


def get_confidence(thresh, df, n, med):
    distrib = df[df['n_sub']==n]
    pct_diff = np.array([distrib['p{0:02}t'.format(a)].iloc[0] for a in range(1,100)])
    x = pct_diff/100*med+med
    y = 1-np.array(range(1,100))/100
    c = np.interp(thresh,x,y)
    return c


# In[8]:


# load sampling uncertainty distributions
os.chdir('/home/wxm/Desktop/2019_CANGZHOU/code/UNCERTAINTY ANALYSIS/result')
df_uncertainty = pd.read_excel('sampleuncertainty_2019Jan.xlsx')
threshold = 51
confidence = []
for i,row in df_1.iterrows():
    n = min(int(row['pass_count']/5)*5,35)
    med = row['median']
    confidence.append(get_confidence(threshold,df_uncertainty,n,med))


# In[9]:


# export results
df_1['confidence'] = confidence
df_1.to_excel ('/home/wxm/Desktop/2019_CANGZHOU/code/UNCERTAINTY ANALYSIS/result/heweiqu_exceeds_threshold_confidence.xlsx', index =False, header=True)


# In[10]:


# visualization
group = df_1
group['location'] = group.apply(lambda group: geohash2.decode(group['geohash_coded']), axis=1)
group['location'] = group['location'].astype('str')
group['location'] = group['location'].apply(lambda x: x.replace('\'', ''))

group2 = pd.DataFrame()
group2 = group.location.str.extract(
    '^(?P<Location>.*)\s*\((?P<Latitude>[^,]*),\s*(?P<Longitude>\S*)\).*$',
    expand=True
)
group2 = group2.drop('Location', axis=1)
group = pd.concat([group, group2], axis=1)

group.Latitude = group.Latitude.astype(float)
group.Longitude = group.Longitude.astype(float)
group = group[['geohash_coded','location','confidence']]
geometry = group['geohash_coded'].apply(geohash_to_polygon)
group['geometry'] = geometry
group.head()
crs = {'init': 'epsg:4326'}
group_gdf = GeoDataFrame(group, crs=crs, geometry=geometry)


# In[12]:


value_list = [group_gdf['confidence'].min(),group_gdf['confidence'].max()]
print(value_list)
min_value = min(value_list)
max_value = max(value_list)
linear = cm.LinearColormap(['green','yellow','red'], vmin=min_value, vmax=max_value)
linear
group_gdf.to_file("group_gdf.geojson", driver='GeoJSON')
geo_json_data = json.load(open('group_gdf.geojson'))

colormap = linear
colormap.caption = 'probability January median exceeds 51 ug/m3'
fmap = folium.Map([38.317435,116.894054], zoom_start=12)    .add_child(folium.GeoJson(
    geo_json_data,
    style_function=lambda feature: {
        'fillColor': linear(feature['properties']['confidence']),
         'fillOpacity' : 0.5,
         'weight' : 0.5, 'color' : 'gray'
        },
    name = 'probability January median exceeds 51 ug/m3'
    )).add_children(colormap)\
    .add_child(folium.LayerControl(collapsed=True))


# In[13]:


os.chdir('/home/wxm/Desktop/2019_CANGZHOU/code/UNCERTAINTY ANALYSIS/result/')
fmap.save('exceed_threshold_probability.html')


# In[ ]:





# In[ ]:




