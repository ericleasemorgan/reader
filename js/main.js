// Wait for the document to load
$(document).ready(function() {

   $(document).on('click', '.yamm .dropdown-menu', function(e) {
     e.stopPropagation()
   })

   // Find all anchor tags with class of 'dr-smooth-scroll'
   $(".dr-smooth-scroll").click( function (event) {

      // Prevent the default link behavior
      event.preventDefault();

      // Scroll page to the link clicked over .4 seconds
      $("html, body").animate({
         scrollTop: $($(this).attr("href")).offset().top
      }, 400);

   });

});
// document.ready
