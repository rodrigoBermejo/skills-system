# Data Processing - pandas, numpy, Data Analysis

**Scope:** backend  
**Trigger:** cuando se trabaje con procesamiento de datos, análisis de datos, pandas, numpy, manipulación de datos, o data science con Python  
**Tools:** view, file_create, str_replace, bash_tool  
**Version:** 1.0.0  

---

## 🎯 Propósito

Esta skill te guía para procesar y analizar datos con Python. Cubre pandas para manipulación de datos, numpy para operaciones numéricas, limpieza de datos, transformaciones, visualización básica y preparación de datos para machine learning.

## 🔧 Cuándo Usar Esta Skill

- Análisis exploratorio de datos (EDA)
- Limpieza y transformación de datos
- Agregar y resumir datasets
- Procesamiento de CSVs, Excel, JSON
- Preparación de datos para ML
- Reportes y visualizaciones básicas
- ETL pipelines

## 📚 Contexto y Conocimiento

### Stack de Data Processing

```
pandas    - Manipulación de datos (DataFrames)
numpy     - Operaciones numéricas y arrays
matplotlib - Visualización básica
seaborn   - Visualización estadística
openpyxl  - Leer/escribir Excel
```

### Setup

```bash
pip install pandas numpy matplotlib seaborn
pip install openpyxl  # Para Excel
pip install jupyter   # Para notebooks
```

## 📊 NumPy Basics

### Arrays

```python
import numpy as np

# Crear arrays
arr = np.array([1, 2, 3, 4, 5])
arr_2d = np.array([[1, 2, 3], [4, 5, 6]])

# Arrays especiales
zeros = np.zeros((3, 4))         # 3x4 de ceros
ones = np.ones((2, 3))           # 2x3 de unos
eye = np.eye(4)                  # Matriz identidad 4x4
arange = np.arange(0, 10, 2)     # [0, 2, 4, 6, 8]
linspace = np.linspace(0, 1, 5)  # 5 valores entre 0 y 1

# Random
random_arr = np.random.rand(3, 3)        # 3x3 uniform [0,1)
random_int = np.random.randint(0, 10, 5) # 5 enteros [0,10)
normal = np.random.randn(1000)           # Normal distribution

# Propiedades
print(arr.shape)   # (5,)
print(arr.dtype)   # int64
print(arr.size)    # 5
print(arr.ndim)    # 1
```

### Operaciones

```python
# Aritméticas (element-wise)
arr = np.array([1, 2, 3, 4, 5])
arr + 10        # [11, 12, 13, 14, 15]
arr * 2         # [2, 4, 6, 8, 10]
arr ** 2        # [1, 4, 9, 16, 25]
arr / 2         # [0.5, 1., 1.5, 2., 2.5]

# Agregaciones
arr.sum()       # 15
arr.mean()      # 3.0
arr.std()       # Desviación estándar
arr.min()       # 1
arr.max()       # 5
arr.argmax()    # Índice del máximo

# Boolean indexing
arr > 3         # [False, False, False, True, True]
arr[arr > 3]    # [4, 5]

# Reshaping
arr.reshape(5, 1)
arr.flatten()
```

## 🐼 Pandas DataFrames

### Crear DataFrames

```python
import pandas as pd

# Desde dict
data = {
    'name': ['Alice', 'Bob', 'Charlie'],
    'age': [25, 30, 35],
    'city': ['NY', 'SF', 'LA']
}
df = pd.DataFrame(data)

# Desde CSV
df = pd.read_csv('data.csv')
df = pd.read_csv('data.csv', sep=';', encoding='latin-1')

# Desde Excel
df = pd.read_excel('data.xlsx', sheet_name='Sheet1')

# Desde JSON
df = pd.read_json('data.json')

# Desde SQL
import sqlite3
conn = sqlite3.connect('database.db')
df = pd.read_sql_query("SELECT * FROM users", conn)

# Desde dict de listas
df = pd.DataFrame({
    'A': [1, 2, 3],
    'B': [4, 5, 6]
})
```

### Exploración Básica

```python
# Ver datos
df.head()           # Primeras 5 filas
df.tail()           # Últimas 5 filas
df.sample(10)       # 10 filas aleatorias
df.shape            # (filas, columnas)
df.columns          # Nombres de columnas
df.dtypes           # Tipos de datos
df.info()           # Resumen del DataFrame

# Estadísticas
df.describe()       # Estadísticas descriptivas
df['age'].mean()    # Media de columna
df['age'].median()  # Mediana
df['age'].mode()    # Moda
df.corr()           # Matriz de correlación
```

### Selección de Datos

```python
# Por columna
df['name']              # Serie
df[['name', 'age']]     # DataFrame

# Por fila (índice)
df.loc[0]               # Primera fila (por label)
df.iloc[0]              # Primera fila (por posición)
df.loc[0:2]             # Primeras 3 filas
df.iloc[0:2]            # Primeras 2 filas

# Por condición
df[df['age'] > 30]
df[df['city'] == 'NY']
df[(df['age'] > 25) & (df['city'] == 'SF')]
df[df['name'].isin(['Alice', 'Bob'])]

# Query (SQL-like)
df.query('age > 30 and city == "SF"')

# Selección compleja
df.loc[df['age'] > 30, ['name', 'city']]
```

### Limpieza de Datos

```python
# Missing values
df.isnull()                 # Boolean DataFrame
df.isnull().sum()           # Count por columna
df.dropna()                 # Eliminar filas con NaN
df.dropna(axis=1)           # Eliminar columnas con NaN
df.fillna(0)                # Rellenar con 0
df.fillna(df.mean())        # Rellenar con media
df['age'].fillna(df['age'].median(), inplace=True)

# Duplicados
df.duplicated()             # Boolean Series
df.drop_duplicates()        # Eliminar duplicados
df.drop_duplicates(subset=['name'])  # Por columna

# Rename columns
df.rename(columns={'old_name': 'new_name'})
df.columns = ['col1', 'col2', 'col3']

# Change types
df['age'] = df['age'].astype(int)
df['date'] = pd.to_datetime(df['date'])

# Replace values
df['city'].replace('NY', 'New York')
df.replace({'NY': 'New York', 'SF': 'San Francisco'})

# Strip whitespace
df['name'] = df['name'].str.strip()
```

### Transformaciones

```python
# Agregar columnas
df['age_squared'] = df['age'] ** 2
df['full_name'] = df['first_name'] + ' ' + df['last_name']

# Apply functions
df['age_group'] = df['age'].apply(lambda x: 'Adult' if x >= 18 else 'Minor')

def categorize_age(age):
    if age < 18:
        return 'Minor'
    elif age < 65:
        return 'Adult'
    else:
        return 'Senior'

df['category'] = df['age'].apply(categorize_age)

# Map
mapping = {'NY': 'East', 'SF': 'West', 'LA': 'West'}
df['region'] = df['city'].map(mapping)

# Binning
df['age_bin'] = pd.cut(df['age'], bins=[0, 18, 65, 100], labels=['Minor', 'Adult', 'Senior'])

# String operations
df['name_upper'] = df['name'].str.upper()
df['name_length'] = df['name'].str.len()
df['contains_a'] = df['name'].str.contains('a')
```

### Grouping y Aggregation

```python
# Group by
grouped = df.groupby('city')
grouped['age'].mean()
grouped.size()

# Multiple aggregations
df.groupby('city')['age'].agg(['mean', 'min', 'max', 'count'])

# Multiple columns
df.groupby(['city', 'gender'])['age'].mean()

# Custom aggregations
df.groupby('city').agg({
    'age': ['mean', 'std'],
    'salary': 'sum',
    'name': 'count'
})

# Transform
df['age_centered'] = df.groupby('city')['age'].transform(lambda x: x - x.mean())

# Pivot tables
pd.pivot_table(df, values='salary', index='city', columns='gender', aggfunc='mean')
```

### Merge y Join

```python
# Merge (SQL-style)
df1 = pd.DataFrame({'key': ['A', 'B', 'C'], 'value1': [1, 2, 3]})
df2 = pd.DataFrame({'key': ['A', 'B', 'D'], 'value2': [4, 5, 6]})

# Inner join (default)
pd.merge(df1, df2, on='key')

# Left join
pd.merge(df1, df2, on='key', how='left')

# Right join
pd.merge(df1, df2, on='key', how='right')

# Outer join
pd.merge(df1, df2, on='key', how='outer')

# Concat (stack)
pd.concat([df1, df2])                # Vertical
pd.concat([df1, df2], axis=1)        # Horizontal
pd.concat([df1, df2], ignore_index=True)  # Reset index
```

### Sorting

```python
# Por columna
df.sort_values('age')                    # Ascendente
df.sort_values('age', ascending=False)   # Descendente

# Multiple columns
df.sort_values(['city', 'age'])

# Por índice
df.sort_index()
```

## 📈 Visualización con matplotlib/seaborn

```python
import matplotlib.pyplot as plt
import seaborn as sns

# Configuración
sns.set_style('whitegrid')
plt.rcParams['figure.figsize'] = (12, 6)

# Line plot
df.plot(x='date', y='value')
plt.title('Title')
plt.xlabel('X Label')
plt.ylabel('Y Label')
plt.show()

# Bar plot
df['city'].value_counts().plot(kind='bar')
plt.show()

# Histogram
df['age'].hist(bins=20)
plt.show()

# Scatter plot
plt.scatter(df['age'], df['salary'])
plt.xlabel('Age')
plt.ylabel('Salary')
plt.show()

# Box plot
sns.boxplot(x='city', y='age', data=df)
plt.show()

# Heatmap (correlation)
sns.heatmap(df.corr(), annot=True, cmap='coolwarm')
plt.show()

# Multiple plots
fig, axes = plt.subplots(2, 2, figsize=(12, 10))
df['age'].hist(ax=axes[0, 0])
df['salary'].hist(ax=axes[0, 1])
df.plot(x='age', y='salary', kind='scatter', ax=axes[1, 0])
df.boxplot(column='age', by='city', ax=axes[1, 1])
plt.tight_layout()
plt.show()
```

## 🔄 Fechas y Tiempo

```python
# Crear fechas
dates = pd.date_range('2024-01-01', periods=100, freq='D')

# Parsear strings
df['date'] = pd.to_datetime(df['date_str'])

# Extraer componentes
df['year'] = df['date'].dt.year
df['month'] = df['date'].dt.month
df['day'] = df['date'].dt.day
df['dayofweek'] = df['date'].dt.dayofweek
df['quarter'] = df['date'].dt.quarter

# Operaciones
df['date'] + pd.Timedelta(days=7)
df['date_diff'] = df['end_date'] - df['start_date']

# Resample (time series)
df.set_index('date').resample('M').mean()  # Monthly average
df.set_index('date').resample('W').sum()   # Weekly sum
```

## 💾 Exportar Datos

```python
# CSV
df.to_csv('output.csv', index=False)

# Excel
df.to_excel('output.xlsx', sheet_name='Sheet1', index=False)

# Multiple sheets
with pd.ExcelWriter('output.xlsx') as writer:
    df1.to_excel(writer, sheet_name='Sheet1')
    df2.to_excel(writer, sheet_name='Sheet2')

# JSON
df.to_json('output.json', orient='records')

# SQL
df.to_sql('table_name', conn, if_exists='replace', index=False)

# HTML
df.to_html('output.html')
```

## 🎯 Ejemplo Completo: EDA

```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# 1. Cargar datos
df = pd.read_csv('sales_data.csv')

# 2. Exploración inicial
print(df.head())
print(df.info())
print(df.describe())

# 3. Limpieza
# Missing values
print(df.isnull().sum())
df = df.dropna(subset=['price'])
df['quantity'].fillna(df['quantity'].median(), inplace=True)

# Duplicados
df = df.drop_duplicates()

# Tipos
df['date'] = pd.to_datetime(df['date'])
df['price'] = df['price'].astype(float)

# 4. Feature engineering
df['total'] = df['price'] * df['quantity']
df['month'] = df['date'].dt.month
df['year'] = df['date'].dt.year

# 5. Análisis
# Ventas por mes
monthly_sales = df.groupby('month')['total'].sum()
print(monthly_sales)

# Producto más vendido
top_products = df.groupby('product')['quantity'].sum().sort_values(ascending=False).head(10)
print(top_products)

# Correlaciones
print(df[['price', 'quantity', 'total']].corr())

# 6. Visualizaciones
fig, axes = plt.subplots(2, 2, figsize=(15, 10))

# Ventas mensuales
monthly_sales.plot(kind='bar', ax=axes[0, 0], title='Monthly Sales')

# Distribución de precios
df['price'].hist(bins=30, ax=axes[0, 1])
axes[0, 1].set_title('Price Distribution')

# Top productos
top_products.plot(kind='barh', ax=axes[1, 0], title='Top 10 Products')

# Precio vs Cantidad
axes[1, 1].scatter(df['price'], df['quantity'])
axes[1, 1].set_xlabel('Price')
axes[1, 1].set_ylabel('Quantity')
axes[1, 1].set_title('Price vs Quantity')

plt.tight_layout()
plt.savefig('sales_analysis.png')
plt.show()

# 7. Exportar resultados
summary = df.groupby('product').agg({
    'quantity': 'sum',
    'total': 'sum',
    'price': 'mean'
}).round(2)
summary.to_excel('sales_summary.xlsx')
```

## ⚠️ Errores Comunes y Soluciones

| Error | Causa | Solución |
|-------|-------|----------|
| KeyError | Columna no existe | Verificar df.columns |
| SettingWithCopyWarning | Modificación en copia | Usar .copy() o .loc |
| ValueError: could not convert | Tipo de dato incorrecto | Usar pd.to_numeric(errors='coerce') |
| Memory Error | Dataset muy grande | Usar chunks o dask |

## 📋 Checklist de Data Processing

- [ ] Exploración inicial (head, info, describe)
- [ ] Verificar missing values
- [ ] Eliminar duplicados
- [ ] Validar tipos de datos
- [ ] Feature engineering si es necesario
- [ ] Visualizaciones exploratorias
- [ ] Documentar transformaciones
- [ ] Exportar datos limpios
- [ ] Guardar scripts de procesamiento

## 🎓 Best Practices

1. **Explore First** - head(), info(), describe()
2. **Copy DataFrames** - Evitar SettingWithCopyWarning
3. **Inplace=False** - Preferir asignar resultados
4. **Vectorize** - Evitar loops, usar operations
5. **Chain Methods** - df.method1().method2()
6. **Document** - Comentar transformaciones
7. **Validate** - Checks después de transformar
8. **Visualize** - Plots para entender datos
9. **Save Intermediate** - Guardar datasets procesados
10. **Version Control** - Git para notebooks y scripts

---

**Última actualización:** Fase 5 - Skills Python Stack  
**Mantenedor:** Sistema de Skills  
**Siguiente:** Sistema completo listo para producción
