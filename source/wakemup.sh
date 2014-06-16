{
  IFS=","
  while read name mac desc; do
    ../bin/swakeup $mac
  done
} < $1