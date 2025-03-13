<script type="text/javascript">
    function downloadMergedVideo(url) {
        const a = document.createElement('a');
        a.href = url;
        a.download = 'merged_video.webm'; // Suggested filename
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
    }

    async function getBlobFromUrl(blobUrl) {
  // Create a new Request object using the Blob URL
  const response = await fetch(blobUrl);

  // The response object contains the Blob data
  const blob = await response.blob();

  return blob;
}

  async function mergeVideos(blobUrls) {
  const { createFFmpeg, fetchFile } = FFmpeg;
  const ffmpeg = createFFmpeg({ log: true });

  await ffmpeg.load();

  // Convert Blob URLs to Blobs
  const blobs = await Promise.all(blobUrls.map(getBlobFromUrl));

  // Write the Blob files to FFmpeg
  for (let i = 0; i < blobs.length; i++) {
    let fileName = `input${i}.mp4`;
    ffmpeg.FS('writeFile', fileName, await fetchFile(blobs[i]));  // Pass the Blob to FFmpeg
  }

  // Create file list for FFmpeg concatenation
  let fileList = blobs.map((_, i) => `file 'input${i}.mp4'`).join("\n");
  ffmpeg.FS('writeFile', 'fileList.txt', new TextEncoder().encode(fileList));

  // Run FFmpeg to merge videos using copy codec
 await ffmpeg.run(
  '-f', 'concat',
  '-safe', '0',
  '-i', 'fileList.txt',
  '-c:v', 'copy',  // Use the existing VP8 video codec
  '-c:a', 'copy',  // Copy the existing audio codec
  'output.webm'
);



  // Get merged video
  const data = ffmpeg.FS('readFile', 'output.webm');

  // Create a downloadable link
  const videoBlob = new Blob([data.buffer], { type: 'video/webm' });
  const url = URL.createObjectURL(videoBlob);
  const a = document.createElement('a');
  a.href = url;
  a.download = 'merged_video.webm';
  document.body.appendChild(a);
  a.click();
  URL.revokeObjectURL(url);
}




  </script>