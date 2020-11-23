
# Note

## 4手までは、初手から `ABCD` 以外の全てのパタンが出現する。

    ```
        depth  3
    theory.count=59, actual.count=54 (theory - actual).count = 5, (actual - theory).count=0
        depth  4
    theory.count=483, actual.count=449 (theory - actual).count = 34, (actual - theory).count=0
        depth  5
    theory.count=4427, actual.count=4068 (theory - actual).count = 359, (actual - theory).count=0
        depth  6
    theory.count=42699, actual.count=25424 (theory - actual).count = 17275, (actual - theory).count=0
        depth  7
    theory.count=420779, actual.count=54937 (theory - actual).count = 365842, (actual - theory).count=0
        depth  8
    theory.count=4183083, actual.count=64048 (theory - actual).count = 4119035, (actual - theory).count=0
    ```

## <N手>-<C色> 全消し

```
N   Colors  count   portion
 2       1       1    0.0 %
 3       1       1    0.0 %
 4       1       1    0.0 %
 4       2      11    0.0 %
 5       2      67    0.1 %
 6       2      68    0.1 %
 6       3     312    0.4 %
 7       2      25    0.0 %
 7       3    1275    1.9 %
 8       2       4    0.0 %
 8       3    1290    1.9 %
 8       4    2162    3.2 %
 9       3     972    1.4 %
 9       4    7826   11.9 %
10       3     580    0.8 %
10       4   18146   27.6 %
10       5   18146   27.6 %
```
