import gl
import glob
import re

con_name = ['absolute', 'relative']


for con in range(2):

    if con_name[con] == 'absolute':
        maxt=16
    elif con_name[con] == 'relative':
        maxt=8

    post = 'G:/Effort/analysis/rsa_analysis/LDC_distance/Searchlight_10mm/SecondLevel/{}/spmT_0002.nii'.format(con_name[con])

    posthreshfile = 'G:/Effort/analysis/rsa_analysis/LDC_distance/Searchlight_10mm/SecondLevel/{}/spmT_0002_FDR_p025.nii'.format(con_name[con])

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
    gl.overlayload(posthreshfile)
    gl.minmax(1, 0,maxt)
    gl.opacity(1,70)
    #gl.colorname (1,"4hot")
    gl.colorname (1,"8redyell")
    gl.colorfromzero(1,1)
    gl.hiddenbycutout(1,1)

    #gl.mosaic("S R -0 Z 0.35 0.45 S 0.55 0.65 R 0");
    gl.mosaic("H -0.03 S R -0 Z 0.333 S 0.55 0.666 R 0");

    #gl.wait(500)
    #break
    gl.savebmp('G:/Effort/analysis/rsa_analysis/LDC_distance/Searchlight_10mm/SecondLevel/{}/{}.bmp'.format(con_name[con],con_name[con]))


