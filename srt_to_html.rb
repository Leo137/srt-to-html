def srt_to_html(input_file, output_file)
  srt_content = File.read(input_file, encoding: 'utf-8').force_encoding('utf-8')

  html_content = "<html>\n<body>\n"

  html_content += <<~STYLE
    <style>
    .text-line {
      padding-top: 10px;
      padding-bottom: 10px;
    }

    .number, .timestamp {
      color: gray;
      font-size: 10px;
      opacity: 0.7;
      user-select: none;
    }

    .text {
      font-size: 20px;
    }
    </style>
  STYLE

  html_content += <<~SCRIPT
    <script>
      document.addEventListener('keydown', function(event) {
        // Check if the pressed key is Left (ArrowLeft) or Right (ArrowRight)
        console.log(event.keyCode);
        if (event.keyCode === 32) {
           event. preventDefault();
           return;
        }
        if (event.keyCode  === 37 || event.keyCode  === 39) {
          // Get the current subtitle number from the URL
          var currentNumber = parseInt(window.location.hash.substr(2)) || 1;

          // Update the subtitle number based on the pressed key
          var newNumber = (event.keyCode === 37) ? Math.max(1, currentNumber - 1) : currentNumber + 1;

          // Update the URL with the new subtitle number
          window.location.hash = 'i' + newNumber;
        }
      });

      document.addEventListener('DOMContentLoaded', function () {
        // Define an array of dialog IDs
        var dialogs = document.getElementsByClassName("text-line")

        // Function to update URL based on scroll position
        function updateUrl() {

          // Get the current scroll position
          var scrollPosition = (window.scrollY || window.pageYOffset) -20;

          // Iterate through dialog IDs
          for (var i = 0; i < dialogs.length; i++) {
            // Get the offsetTop of the current dialog
            var dialogOffset = dialogs[i].offsetTop;

            // Check if the scroll position is past the current dialog
            if (scrollPosition < dialogOffset) {
              // Update the URL with the current dialog ID
              window.location.hash = dialogs[i].id;
              return;
            }
          }
        }

        // Add scroll event listener to update URL
        window.addEventListener('scroll', updateUrl);

        // Initial call to set URL based on the initial scroll position
        updateUrl();
      })
    </script>
  SCRIPT

  srt_content.scan(/(\d+)[^\n]+\n(\d+:\d+:\d+,\d+) --> (\d+:\d+:\d+,\d+)[^\n]+\n(.*?)(?=\n\d|\z)/m) do |number, start_time, end_time, text|
    html_content += "  <div class='text-line' id='i#{number}'>\n"
    html_content += "    <div class='number'>#{number}</div>\n"
    html_content += "    <div class='timestamp'>#{start_time} --> #{end_time}</div>\n"
    html_content += "    <div class='text'>#{text.gsub("\n", '<br />').strip}</div>\n"
    html_content += "  </div>\n"
  end

  html_content += "</body>\n</html>"

  File.write(output_file, html_content)
end

if ARGV.length != 1
  puts "Usage: ruby srt_to_html.rb <file_path>"
  exit(1)
end

input_file = File.expand_path(ARGV[0])
output_file = "#{File.basename(input_file, '.*')}_output.html"

# Example usage:
srt_to_html(input_file, output_file)
puts "HTML file generated: #{output_file}"
