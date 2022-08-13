import gl
import glob
import re

for con in glob.glob('Z:\Tanya\Task_episodes\SecondLevel_00020\*SecondLevel*'):
  print(con)

  #print(re.sub('.*\~.*baseline', 'meanvbaseline', con))
  if re.sub('.*\~.*baseline', 'meanvbaseline', con) == 'meanvbaseline':
    maxt=50
  else:
    maxt=15
  
  post=con+'\spmT_0002.nii'
  negt=con+'\spmT_0003.nii'
  
  posthreshfile = glob.glob(con + '\*2_FDR0p025*nii')
  negthreshfile = glob.glob(con + '\*3_FDR0p025*nii')

  posthresh =re.sub('.*_t', '', posthreshfile[0])
  negthresh =re.sub('.*_t', '', negthreshfile[0])
  
  posthresh =float(re.sub('.nii', '', posthresh))
  negthresh =float(re.sub('.nii', '', negthresh))

  gl.resetdefaults()
  gl.backcolor(255, 255,255)
  gl.shadername("overlaysurface")
  gl.shaderadjust('overlayDepth', 10)
  gl.shaderadjust('brighten', 2.5)
  gl.shaderadjust('overlayOpacity', 1)
  gl.shaderadjust('surfaceColor', 0.5)
  gl.shadermatcap('Porcelain')
  gl.overlayloadsmooth(1)
  gl.loadimage('spm152')
  gl.azimuthelevation(90,0)
  gl.shaderquality1to10(6)
  gl.overlaymaskwithbackground(1)
  gl.colorbarsize(0.03)
  gl.colorbarposition(0)

  #open overlay: show positive regions
  gl.overlayload(post)
  gl.minmax(1, posthresh,maxt)
  gl.opacity(1,70)
  #gl.colorname (1,"4hot")
  gl.colorname (1,"8redyell")
  gl.colorfromzero(1,1)
  gl.hiddenbycutout(1,1)

  #open overlay: show negative regions
  gl.overlayload(negt)
  gl.minmax(2, negthresh, maxt)
  gl.opacity(2,70)
  gl.colorname (2,"electric_blue")
  gl.colorfromzero(2,1)
  gl.hiddenbycutout(2,1)

  #gl.mosaic("S R -0 Z 0.35 0.45 S 0.55 0.65 R 0");
  gl.mosaic("H -0.03 S R -0 Z 0.333 S 0.55 0.666 R 0");

  #gl.wait(500)
  #break
  gl.savebmp(re.sub('_t.*', '.bmp', posthreshfile[0]))