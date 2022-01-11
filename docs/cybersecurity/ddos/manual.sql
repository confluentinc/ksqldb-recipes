INSERT INTO network_traffic (TIMESTAMP, layers)
VALUES (
  UNIX_TIMESTAMP(), 
  STRUCT(
    frame := STRUCT(time  := 'time', protocols := 'protocols'),
    eth   := STRUCT(src   := 'src',  dst       := 'dst'),
    ip    := STRUCT(src   := 'src',  src_host  := 'src_host',
                    dst   := 'dst',  dst_host  := 'dst_host',
                    proto := 'proto'),
    tcp   := STRUCT(srcport   := 'srcport',  dstport     := 'dstport',
                    flags_ack := 'flags_ack',flags_reset := 'flags_reset')
  )
);
  
