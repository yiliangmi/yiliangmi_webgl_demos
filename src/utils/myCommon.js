/**
 * 每个画布都有两个尺寸，一个是 drawingbuffer 的尺寸， 这个表示画布中有多少个像素。另一是画布显示的尺寸， CSS决定画布显示的尺寸
 * 设置画布的显示尺寸和 画布的drawingbuffer尺寸相同
 * @param canvas canvas对象
 * @returns {boolean}
 */
export function resizeCanvasToDisplaySize(canvas) {
    // Lookup the size the browser is displaying the canvas in CSS pixels.
    const displayWidth = canvas.clientWidth;
    const displayHeight = canvas.clientHeight;

    // Check if the canvas is not the same size.
    const needResize = canvas.width !== displayWidth ||
        canvas.height !== displayHeight;

    if (needResize) {
        // Make the canvas the same size
        canvas.width = displayWidth;
        canvas.height = displayHeight;
    }

    return needResize;
}
