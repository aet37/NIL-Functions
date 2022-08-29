function blkHdr = getBlkHdr( fp ) 
% getBlkHdr returns the block header of an fid filePointer
fseek(fp,32,'bof');
blkHdr.scale = fread( fp, 1, 'int16');
blkHdr.status = fread( fp, 1, 'int16');
blkHdr.index = fread( fp, 1, 'int16');
blkHdr.spare3 = fread( fp, 1, 'int16');
blkHdr.ctcount = fread( fp, 1, 'int32');
blkHdr.lpval = fread( fp, 1, 'float32');
blkHdr.rpval = fread( fp, 1, 'float32');
blkHdr.lvl = fread( fp, 1, 'float32');
blkHdr.tlt = fread( fp, 1, 'float32');
