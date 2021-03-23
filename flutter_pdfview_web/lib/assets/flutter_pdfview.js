requirejs.config({
  baseUrl: 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.3.200',
  paths: {
    'pdfjs-dist/build/pdf': 'pdf.min',
    'pdfjs-dist/build/pdf.worker': 'pdf.worker.min',
  }
});

var flutter_pdfview_web;

requirejs(['pdfjs-dist/build/pdf', 'pdfjs-dist/build/pdf.worker'], function(pdfjsLib, pdfjsWorker) {
  pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.3.200/pdf.worker.min.js';

  class FlutterPDFView {
    constructor(canvas, path, data, defaultPage, onRender, onError) {
      this.canvas = canvas;
      this.pdfDoc = null;
      this.currentPage = 0;

      var self = this;
      if (path != null) var task = pdfjsLib.getDocument(path);
      if (data != null) var task = pdfjsLib.getDocument({data: data});
      task.promise.then(function(pdf) {
        self.pdfDoc = pdf;
        self.setPage(defaultPage);
        onRender(self.pdfDoc.numPages);
      });
      return true;
    }

    getPageCount() {
      return (this.pdfDoc != null) ? this.pdfDoc.numPages : 0;
    }

    getCurrentPage() {
      return this.currentPage;
    }

    setPage(pageIndex, onChange, onError) {
      var self = this;
      this.pdfDoc.getPage(pageIndex).then(function(page) {
        var viewport = page.getViewport({ scale: 1.0 });
        self.canvas.height = viewport.height;
        self.canvas.width = viewport.width;
        var context = self.canvas.getContext('2d');
        page.render({ canvasContext: context, viewport: viewport });
        self.currentPage = pageIndex;
        if (onChange != null) onChange(self.currentPage, self.pdfDoc.numPages);
        return true;
      });

      if (onError != null) onError(pageIndex, 'canvas not found');
      return false;
    }
  }

  flutter_pdfview_web = {
    getPageCount: function(canvas) {
      return canvas.FlutterPDFView.getPageCount();
    },

    getCurrentPage: function(canvas) {
      return canvas.FlutterPDFView.currentPage;
    },

    setPage: function(canvas, pageIndex, onChange, onError) {
      return canvas.FlutterPDFView.setPage(pageIndex, onChange, onError);
    },

    createPath: function(canvas, path, defaultPage, onRender, onError) {
      canvas.FlutterPDFView = new FlutterPDFView(canvas, path, null, defaultPage, onRender, onError);
    },

    createData: function(canvas, data, defaultPage, onRender, onError) {
      canvas.FlutterPDFView = new FlutterPDFView(canvas, null, data, defaultPage, onRender, onError);
    },
  };

  window.dispatchEvent(new Event('flutter_pdfview_web_ready'));
});
