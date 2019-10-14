var dropzoneUploading = false;

$(function () {
    Dropzone.options.renderNewDocument = {
        autoProcessQueue: false, // Prevents Dropzone from uploading dropped files immediately
        paramName: 'image[rendering_image]',
        parallelUploads: 5,
        previewsContainer: '#render-dropzone-previews',
        clickable: '#render-dropzone-top',
        previewTemplate: '<div class="file-row"> <div><p class="name" data-dz-name></p><strong class="error text-danger" data-dz-errormessage></strong></div> <div><p class="size" data-dz-size></p></div> <div> <div class="progress progress-striped active" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0"> <div class="progress-bar progress-bar-success" style="width:0%;" data-dz-uploadprogress></div> </div> </div> <div> <a href="#" data-dz-remove> <i title="Remove upload" data-toggle="tooltip" class="fa fa-lg fa-trash" style="padding-right: 10px;"></i></a> </div> </div>',
        maxFilesize: $('form.dropzone').data('maxfilesize'), // in MB
        acceptedFiles: $('form.dropzone').data('acceptedfiles'),
        timeout: 0,

        init: function () {
            var documentsDropzone = this;
            var dropzoneTop = $("#render-dropzone-top");
            var dropzoneBottom = $("#render-dropzone-bottom");
            var dropzoneModal = $("#render-dropzone-modal");
            var uploadButton = $("#render-dropzone-upload-all");
            var previewsContainer = $("#render-dropzone-previews");
            var uploadErrors = [];

            // Process all queued files when the upload button is clicked
            uploadButton.click(function (e) {
                if (!dropzoneUploading) {
                    // All rejected files should first be removed from the queue list
                    if (documentsDropzone.getRejectedFiles().length > 0) {
                        // Show a modal box
                        dropzoneModal.find('.modal-title').html('<i class="fa fa-exclamation-circle"></i>&nbsp;&nbsp;Validation error');
                        dropzoneModal.find('.modal-body').html('Please remove all invalid files before uploading.');
                        dropzoneModal.find('.modal-header').attr('class', 'modal-header alert-danger');
                        dropzoneModal.modal('show');
                    }
                    else {
                        dropzoneUploading = true;
                        documentsDropzone.processQueue();
                    }
                }
                e.preventDefault();
            });

            // Show the previews container and upload button when one or more files are added
            this.on("addedfile", function () {
                dropzoneBottom.slideDown();
            });
            // Hide the previews container and upload button when all files are removed
            this.on("removedfile", function () {
                if (previewsContainer.children().length == 1) {
                    dropzoneBottom.slideUp();
                }
            });
            // Once the upload button is clicked, the full queue can be processed
            this.on("processing", function () {
                this.options.autoProcessQueue = true;
                uploadButton.html('<i class="fa fa-lg fa-cog fa-spin"></i>&nbsp;&nbsp;Please wait...');
                uploadButton.prop('disabled', true);
                dropzoneTop.hide();
            });
            // Catch all server errors
            this.on("error", function (file, errorMessage, XMLHttpRequest) {
                // Errors returned by the server
                if (XMLHttpRequest !== undefined) {
                    uploadErrors.push('<strong>' + file.name + '</strong>: ' + errorMessage);
                }
                // Errors on the client side
                else {
                    // These errors are shown in the file row
                }
            });
            // Notify the user when all uploads are completed
            this.on("queuecomplete", function () {
                if (dropzoneUploading) {
                    var modalBody = '';
                    var modalHeaderClass = '';

                    // There were server errors during the upload
                    if (uploadErrors.length > 0) {
                        modalBody = '<div>Some images weren\'t successfully uploaded because of the following errors:</div>';

                        modalBody += '<ul>';
                        $.each(uploadErrors, function (index, uploadError) {
                            modalBody += '<li>' + uploadError + '</li>';
                        });
                        modalBody += '</ul>';

                        modalBody += '<div>All other project rendering images were uploaded successfully.</div>';
                        modalHeaderClass = 'alert-warning';
                    }
                    // There were no errors
                    else {
                        modalBody = 'All project rendering images were successfully uploaded.';
                        modalHeaderClass = 'alert-success';
                    }

                    // Show a modal box
                    dropzoneModal.find('.modal-title').html('<i class="fa fa-check-circle"></i>&nbsp;&nbsp;Uploading completed');
                    dropzoneModal.find('.modal-body').html(modalBody);
                    dropzoneModal.find('.modal-header').attr('class', 'modal-header ' + modalHeaderClass);
                    dropzoneModal.modal('show');
                }
            });
        }
    };

    // Handle closing of modal box
    $('#render-dropzone-modal').on('hide.bs.modal', function (e) {
        // Reload the page when the upload notification is closed by the user
        if (dropzoneUploading) {
            location.reload();
        }
    });
});
