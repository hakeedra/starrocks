[sql]
select
    supp_nation,
    cust_nation,
    l_year,
    sum(volume) as revenue
from
    (
        select
            n1.n_name as supp_nation,
            n2.n_name as cust_nation,
            extract(year from l_shipdate) as l_year,
            l_extendedprice * (1 - l_discount) as volume
        from
            supplier,
            lineitem,
            orders,
            customer,
            nation n1,
            nation n2
        where
                s_suppkey = l_suppkey
          and o_orderkey = l_orderkey
          and c_custkey = o_custkey
          and s_nationkey = n1.n_nationkey
          and c_nationkey = n2.n_nationkey
          and (
                (n1.n_name = 'CANADA' and n2.n_name = 'IRAN')
                or (n1.n_name = 'IRAN' and n2.n_name = 'CANADA')
            )
          and l_shipdate between date '1995-01-01' and date '1996-12-31'
    ) as shipping
group by
    supp_nation,
    cust_nation,
    l_year
order by
    supp_nation,
    cust_nation,
    l_year ;
[fragment statistics]
PLAN FRAGMENT 0(F14)
Output Exprs:42: n_name | 46: n_name | 49: year | 51: sum
Input Partition: UNPARTITIONED
RESULT SINK

26:MERGING-EXCHANGE
cardinality: 250
column statistics:
* n_name-->[-Infinity, Infinity, 0.0, 25.0, 25.0] ESTIMATE
* n_name-->[-Infinity, Infinity, 0.0, 25.0, 25.0] ESTIMATE
* year-->[1995.0, 1996.0, 0.0, 2.0, 2.0] ESTIMATE
* sum-->[810.9, 104949.5, 0.0, 16.0, 250.28228759765625] ESTIMATE

PLAN FRAGMENT 1(F13)

Input Partition: HASH_PARTITIONED: 42: n_name, 46: n_name, 49: year
OutPut Partition: UNPARTITIONED
OutPut Exchange Id: 26

25:SORT
|  order by: [42, VARCHAR, true] ASC, [46, VARCHAR, true] ASC, [49, SMALLINT, true] ASC
|  offset: 0
|  cardinality: 250
|  column statistics:
|  * n_name-->[-Infinity, Infinity, 0.0, 25.0, 25.0] ESTIMATE
|  * n_name-->[-Infinity, Infinity, 0.0, 25.0, 25.0] ESTIMATE
|  * year-->[1995.0, 1996.0, 0.0, 2.0, 2.0] ESTIMATE
|  * sum-->[810.9, 104949.5, 0.0, 16.0, 250.28228759765625] ESTIMATE
|
24:AGGREGATE (merge finalize)
|  aggregate: sum[([51: sum, DECIMAL128(38,4), true]); args: DECIMAL128; result: DECIMAL128(38,4); args nullable: true; result nullable: true]
|  group by: [42: n_name, VARCHAR, true], [46: n_name, VARCHAR, true], [49: year, SMALLINT, true]
|  cardinality: 250
|  column statistics:
|  * n_name-->[-Infinity, Infinity, 0.0, 25.0, 25.0] ESTIMATE
|  * n_name-->[-Infinity, Infinity, 0.0, 25.0, 25.0] ESTIMATE
|  * year-->[1995.0, 1996.0, 0.0, 2.0, 2.0] ESTIMATE
|  * sum-->[810.9, 104949.5, 0.0, 16.0, 250.28228759765625] ESTIMATE
|
23:EXCHANGE
cardinality: 297

PLAN FRAGMENT 2(F06)

Input Partition: HASH_PARTITIONED: 8: l_orderkey
OutPut Partition: HASH_PARTITIONED: 42: n_name, 46: n_name, 49: year
OutPut Exchange Id: 23

22:AGGREGATE (update serialize)
|  STREAMING
|  aggregate: sum[([50: expr, DECIMAL128(33,4), true]); args: DECIMAL128; result: DECIMAL128(38,4); args nullable: true; result nullable: true]
|  group by: [42: n_name, VARCHAR, true], [46: n_name, VARCHAR, true], [49: year, SMALLINT, true]
|  cardinality: 297
|  column statistics:
|  * n_name-->[-Infinity, Infinity, 0.0, 25.0, 25.0] ESTIMATE
|  * n_name-->[-Infinity, Infinity, 0.0, 25.0, 25.0] ESTIMATE
|  * year-->[1995.0, 1996.0, 0.0, 2.0, 2.0] ESTIMATE
|  * sum-->[810.9, 104949.5, 0.0, 16.0, 296.630859375] ESTIMATE
|
21:Project
|  output columns:
|  42 <-> [42: n_name, VARCHAR, true]
|  46 <-> [46: n_name, VARCHAR, true]
|  49 <-> year[([18: l_shipdate, DATE, true]); args: DATE; result: SMALLINT; args nullable: true; result nullable: true]
|  50 <-> cast([13: l_extendedprice, DECIMAL64(15,2), true] as DECIMAL128(15,2)) * cast(1 - [14: l_discount, DECIMAL64(15,2), true] as DECIMAL128(18,2))
|  cardinality: 554680
|  column statistics:
|  * n_name-->[-Infinity, Infinity, 0.0, 25.0, 25.0] ESTIMATE
|  * n_name-->[-Infinity, Infinity, 0.0, 25.0, 25.0] ESTIMATE
|  * year-->[1995.0, 1996.0, 0.0, 2.0, 2.0] ESTIMATE
|  * expr-->[810.9, 104949.5, 0.0, 16.0, 277562.0869449505] ESTIMATE
|
20:HASH JOIN
|  join op: INNER JOIN (BROADCAST)
|  equal join conjunct: [36: c_nationkey, INT, true] = [45: n_nationkey, INT, true]
|  other join predicates: ((42: n_name = 'CANADA') AND (46: n_name = 'IRAN')) OR ((42: n_name = 'IRAN') AND (46: n_name = 'CANADA'))
|  build runtime filters:
|  - filter_id = 3, build_expr = (45: n_nationkey), remote = true
|  output columns: 13, 14, 18, 42, 46
|  cardinality: 554680
|  column statistics:
|  * l_extendedprice-->[901.0, 104949.5, 0.0, 8.0, 277562.0869449505] ESTIMATE
|  * l_discount-->[0.0, 0.1, 0.0, 8.0, 11.0] ESTIMATE
|  * l_shipdate-->[7.888896E8, 8.519616E8, 0.0, 4.0, 2526.0] ESTIMATE
|  * c_nationkey-->[0.0, 24.0, 0.0, 4.0, 25.0] ESTIMATE
|  * n_name-->[-Infinity, Infinity, 0.0, 25.0, 25.0] ESTIMATE
|  * n_nationkey-->[0.0, 24.0, 0.0, 4.0, 25.0] ESTIMATE
|  * n_name-->[-Infinity, Infinity, 0.0, 25.0, 25.0] ESTIMATE
|  * year-->[1995.0, 1996.0, 0.0, 2.0, 2.0] ESTIMATE
|  * expr-->[810.9, 104949.5, 0.0, 16.0, 277562.0869449505] ESTIMATE
|
|----19:EXCHANGE
|       cardinality: 25
|
17:Project
|  output columns:
|  13 <-> [13: l_extendedprice, DECIMAL64(15,2), true]
|  14 <-> [14: l_discount, DECIMAL64(15,2), true]
|  18 <-> [18: l_shipdate, DATE, true]
|  36 <-> [36: c_nationkey, INT, true]
|  42 <-> [42: n_name, VARCHAR, true]
|  cardinality: 173476304
|  column statistics:
|  * l_extendedprice-->[901.0, 104949.5, 0.0, 8.0, 3736520.0] ESTIMATE
|  * l_discount-->[0.0, 0.1, 0.0, 8.0, 11.0] ESTIMATE
|  * l_shipdate-->[7.888896E8, 8.519616E8, 0.0, 4.0, 2526.0] ESTIMATE
|  * c_nationkey-->[0.0, 24.0, 0.0, 4.0, 25.0] ESTIMATE
|  * n_name-->[-Infinity, Infinity, 0.0, 25.0, 25.0] ESTIMATE
|
16:HASH JOIN
|  join op: INNER JOIN (BROADCAST)
|  equal join conjunct: [10: l_suppkey, INT, true] = [1: s_suppkey, INT, true]
|  build runtime filters:
|  - filter_id = 2, build_expr = (1: s_suppkey), remote = true
|  output columns: 13, 14, 18, 36, 42
|  cardinality: 173476304
|  column statistics:
|  * s_suppkey-->[1.0, 1000000.0, 0.0, 4.0, 1000000.0] ESTIMATE
|  * l_suppkey-->[1.0, 1000000.0, 0.0, 4.0, 1000000.0] ESTIMATE
|  * l_extendedprice-->[901.0, 104949.5, 0.0, 8.0, 3736520.0] ESTIMATE
|  * l_discount-->[0.0, 0.1, 0.0, 8.0, 11.0] ESTIMATE
|  * l_shipdate-->[7.888896E8, 8.519616E8, 0.0, 4.0, 2526.0] ESTIMATE
|  * c_nationkey-->[0.0, 24.0, 0.0, 4.0, 25.0] ESTIMATE
|  * n_name-->[-Infinity, Infinity, 0.0, 25.0, 25.0] ESTIMATE
|
|----15:EXCHANGE
|       cardinality: 1000000
|
9:Project
|  output columns:
|  10 <-> [10: l_suppkey, INT, true]
|  13 <-> [13: l_extendedprice, DECIMAL64(15,2), true]
|  14 <-> [14: l_discount, DECIMAL64(15,2), true]
|  18 <-> [18: l_shipdate, DATE, true]
|  36 <-> [36: c_nationkey, INT, true]
|  cardinality: 173476304
|  column statistics:
|  * l_suppkey-->[1.0, 1000000.0, 0.0, 4.0, 1000000.0] ESTIMATE
|  * l_extendedprice-->[901.0, 104949.5, 0.0, 8.0, 3736520.0] ESTIMATE
|  * l_discount-->[0.0, 0.1, 0.0, 8.0, 11.0] ESTIMATE
|  * l_shipdate-->[7.888896E8, 8.519616E8, 0.0, 4.0, 2526.0] ESTIMATE
|  * c_nationkey-->[0.0, 24.0, 0.0, 4.0, 25.0] ESTIMATE
|
8:HASH JOIN
|  join op: INNER JOIN (PARTITIONED)
|  equal join conjunct: [8: l_orderkey, INT, true] = [24: o_orderkey, INT, true]
|  output columns: 10, 13, 14, 18, 36
|  cardinality: 173476304
|  column statistics:
|  * l_orderkey-->[1.0, 6.0E8, 0.0, 8.0, 1.5E8] ESTIMATE
|  * l_suppkey-->[1.0, 1000000.0, 0.0, 4.0, 1000000.0] ESTIMATE
|  * l_extendedprice-->[901.0, 104949.5, 0.0, 8.0, 3736520.0] ESTIMATE
|  * l_discount-->[0.0, 0.1, 0.0, 8.0, 11.0] ESTIMATE
|  * l_shipdate-->[7.888896E8, 8.519616E8, 0.0, 4.0, 2526.0] ESTIMATE
|  * o_orderkey-->[1.0, 6.0E8, 0.0, 8.0, 1.5E8] ESTIMATE
|  * c_nationkey-->[0.0, 24.0, 0.0, 4.0, 25.0] ESTIMATE
|
|----7:EXCHANGE
|       cardinality: 150000000
|       probe runtime filters:
|       - filter_id = 3, probe_expr = (36: c_nationkey)
|
1:EXCHANGE
cardinality: 173476304
probe runtime filters:
- filter_id = 2, probe_expr = (10: l_suppkey)

PLAN FRAGMENT 3(F11)

Input Partition: RANDOM
OutPut Partition: UNPARTITIONED
OutPut Exchange Id: 19

18:HdfsScanNode
TABLE: nation
NON-PARTITION PREDICATES: 46: n_name IN ('IRAN', 'CANADA')
MIN/MAX PREDICATES: 52: n_name >= 'CANADA', 53: n_name <= 'IRAN'
partitions=1/1
avgRowSize=29.0
numNodes=0
cardinality: 25
column statistics:
* n_nationkey-->[0.0, 24.0, 0.0, 4.0, 25.0] ESTIMATE
* n_name-->[-Infinity, Infinity, 0.0, 25.0, 25.0] ESTIMATE

PLAN FRAGMENT 4(F07)

Input Partition: RANDOM
OutPut Partition: UNPARTITIONED
OutPut Exchange Id: 15

14:Project
|  output columns:
|  1 <-> [1: s_suppkey, INT, true]
|  42 <-> [42: n_name, VARCHAR, true]
|  cardinality: 1000000
|  column statistics:
|  * s_suppkey-->[1.0, 1000000.0, 0.0, 4.0, 1000000.0] ESTIMATE
|  * n_name-->[-Infinity, Infinity, 0.0, 25.0, 25.0] ESTIMATE
|
13:HASH JOIN
|  join op: INNER JOIN (BROADCAST)
|  equal join conjunct: [4: s_nationkey, INT, true] = [41: n_nationkey, INT, true]
|  build runtime filters:
|  - filter_id = 1, build_expr = (41: n_nationkey), remote = false
|  output columns: 1, 42
|  cardinality: 1000000
|  column statistics:
|  * s_suppkey-->[1.0, 1000000.0, 0.0, 4.0, 1000000.0] ESTIMATE
|  * s_nationkey-->[0.0, 24.0, 0.0, 4.0, 25.0] ESTIMATE
|  * n_nationkey-->[0.0, 24.0, 0.0, 4.0, 25.0] ESTIMATE
|  * n_name-->[-Infinity, Infinity, 0.0, 25.0, 25.0] ESTIMATE
|
|----12:EXCHANGE
|       cardinality: 25
|
10:HdfsScanNode
TABLE: supplier
NON-PARTITION PREDICATES: 1: s_suppkey IS NOT NULL
partitions=1/1
avgRowSize=8.0
numNodes=0
cardinality: 1000000
probe runtime filters:
- filter_id = 1, probe_expr = (4: s_nationkey)
column statistics:
* s_suppkey-->[1.0, 1000000.0, 0.0, 4.0, 1000000.0] ESTIMATE
* s_nationkey-->[0.0, 24.0, 0.0, 4.0, 25.0] ESTIMATE

PLAN FRAGMENT 5(F08)

Input Partition: RANDOM
OutPut Partition: UNPARTITIONED
OutPut Exchange Id: 12

11:HdfsScanNode
TABLE: nation
NON-PARTITION PREDICATES: 42: n_name IN ('CANADA', 'IRAN')
MIN/MAX PREDICATES: 54: n_name >= 'CANADA', 55: n_name <= 'IRAN'
partitions=1/1
avgRowSize=29.0
numNodes=0
cardinality: 25
column statistics:
* n_nationkey-->[0.0, 24.0, 0.0, 4.0, 25.0] ESTIMATE
* n_name-->[-Infinity, Infinity, 0.0, 25.0, 25.0] ESTIMATE

PLAN FRAGMENT 6(F02)

Input Partition: RANDOM
OutPut Partition: HASH_PARTITIONED: 24: o_orderkey
OutPut Exchange Id: 07

6:Project
|  output columns:
|  24 <-> [24: o_orderkey, INT, true]
|  36 <-> [36: c_nationkey, INT, true]
|  cardinality: 150000000
|  column statistics:
|  * o_orderkey-->[1.0, 6.0E8, 0.0, 8.0, 1.5E8] ESTIMATE
|  * c_nationkey-->[0.0, 24.0, 0.0, 4.0, 25.0] ESTIMATE
|
5:HASH JOIN
|  join op: INNER JOIN (BROADCAST)
|  equal join conjunct: [25: o_custkey, INT, true] = [33: c_custkey, INT, true]
|  build runtime filters:
|  - filter_id = 0, build_expr = (33: c_custkey), remote = false
|  output columns: 24, 36
|  cardinality: 150000000
|  column statistics:
|  * o_orderkey-->[1.0, 6.0E8, 0.0, 8.0, 1.5E8] ESTIMATE
|  * o_custkey-->[1.0, 1.5E7, 0.0, 8.0, 1.0031873E7] ESTIMATE
|  * c_custkey-->[1.0, 1.5E7, 0.0, 8.0, 1.0031873E7] ESTIMATE
|  * c_nationkey-->[0.0, 24.0, 0.0, 4.0, 25.0] ESTIMATE
|
|----4:EXCHANGE
|       cardinality: 15000000
|
2:HdfsScanNode
TABLE: orders
NON-PARTITION PREDICATES: 24: o_orderkey IS NOT NULL
partitions=1/1
avgRowSize=16.0
numNodes=0
cardinality: 150000000
probe runtime filters:
- filter_id = 0, probe_expr = (25: o_custkey)
column statistics:
* o_orderkey-->[1.0, 6.0E8, 0.0, 8.0, 1.5E8] ESTIMATE
* o_custkey-->[1.0, 1.5E8, 0.0, 8.0, 1.0031873E7] ESTIMATE

PLAN FRAGMENT 7(F03)

Input Partition: RANDOM
OutPut Partition: UNPARTITIONED
OutPut Exchange Id: 04

3:HdfsScanNode
TABLE: customer
NON-PARTITION PREDICATES: 33: c_custkey IS NOT NULL
partitions=1/1
avgRowSize=12.0
numNodes=0
cardinality: 15000000
probe runtime filters:
- filter_id = 3, probe_expr = (36: c_nationkey)
column statistics:
* c_custkey-->[1.0, 1.5E7, 0.0, 8.0, 1.5E7] ESTIMATE
* c_nationkey-->[0.0, 24.0, 0.0, 4.0, 25.0] ESTIMATE

PLAN FRAGMENT 8(F00)

Input Partition: RANDOM
OutPut Partition: HASH_PARTITIONED: 8: l_orderkey
OutPut Exchange Id: 01

0:HdfsScanNode
TABLE: lineitem
NON-PARTITION PREDICATES: 18: l_shipdate >= '1995-01-01', 18: l_shipdate <= '1996-12-31'
MIN/MAX PREDICATES: 56: l_shipdate >= '1995-01-01', 57: l_shipdate <= '1996-12-31'
partitions=1/1
avgRowSize=32.0
numNodes=0
cardinality: 173476304
probe runtime filters:
- filter_id = 2, probe_expr = (10: l_suppkey)
column statistics:
* l_orderkey-->[1.0, 6.0E8, 0.0, 8.0, 1.5E8] ESTIMATE
* l_suppkey-->[1.0, 1000000.0, 0.0, 4.0, 1000000.0] ESTIMATE
* l_extendedprice-->[901.0, 104949.5, 0.0, 8.0, 3736520.0] ESTIMATE
* l_discount-->[0.0, 0.1, 0.0, 8.0, 11.0] ESTIMATE
* l_shipdate-->[7.888896E8, 8.519616E8, 0.0, 4.0, 2526.0] ESTIMATE
[end]

