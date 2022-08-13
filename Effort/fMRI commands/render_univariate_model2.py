import gl
import glob
import re


con_name = ['cue_main_effect_prev', 'cue_main_effect_current', 'cue_Switch2Easy_vs_StayEasy', 'cue_Switch2Hard_vs_StayHard',
'task_main_effect_prev', 'task_main_effect_current', 'task_Switch2Easy_vs_StayEasy', 'task_Switch2Hard_vs_StayHard']
p_name = ['con_6', 'con_8', 'con_10', 'con_12', 'con_18', 'con_20', 'con_22', 'con_24'] 
n_name = ['con_5', 'con_7', 'con_9', 'con_11', 'con_17', 'con_19', 'con_21', 'con_23']

for con in range(8):

    maxt=8

    post = 'G:/Effort/analysis/l2output-Effort-Model2/level2/_{}_fwhm_10/level2conestimate/spmT_0001.nii'.format(p_name[con])
    negt = 'G:/Effort/analysis/l2output-Effort-Model2/level2/_{}_fwhm_10/level2conestimate/spmT_0001.nii'.format(n_name[con])

    posthreshfile = 'G:/Effort/analysis/l2output-Effort-Model2/level2/_{}_fwhm_10/level2conestimate/spmT_0001_FDR_p025.nii'.format(p_name[con])
    negthreshfile = 'G:/Effort/analysis/l2output-Effort-Model2/level2/_{}_fwhm_10/level2conestimate/spmT_0001_FDR_p025.nii'.format(n_name[con])

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

    #open overlay: show negative regions
    gl.overlayload(negthreshfile)
    gl.minmax(2, 0, maxt)
    gl.opacity(2,70)
    gl.colorname (2,"electric_blue")
    gl.colorfromzero(2,1)
    gl.hiddenbycutout(2,1)

    #gl.mosaic("S R -0 Z 0.35 0.45 S 0.55 0.65 R 0");
    gl.mosaic("H -0.03 S R -0 Z 0.333 S 0.55 0.666 R 0");

    #gl.wait(500)
    #break
    gl.savebmp('G:/Effort/analysis/l2output-Effort-Model2/level2/{}.bmp'.format(con_name[con]))


