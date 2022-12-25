# This is only a template based on a simple sidebar layout with a leaflet thematic map 

Rfuns::load_pkgs('RpostcodeUK', 'data.table', 'leaflet', 'leaflet.extras', 'sf', 'shiny', 'shinyjs', 'shinyWidgets')
apath <- file.path(app_path, 'XXXXXX')

ui <- fluidPage(

    useShinyjs(),
    faPlugin,
    tags$head(
        tags$title('Postcodes UK. @2022 datamaps'),
        tags$style("@import url('https://datamaps.uk/assets/datamaps/icons/fontawesome/all.css;')"),
        tags$style(HTML("
                h1, h2, h3, h4 { font-weight: 400; }
                body, label, input, button, select { 
                  font-family: 'Helvetica Neue', Helvetica;
                  font-weight: 200;
                }
                div.outer {
                  position: fixed;
                  top: 50px;
                  left: 0;
                  right: 0;
                  bottom: 0;
                  overflow: hidden;
                  padding: 0;
                }
                #controls {
                  background-color: white;
                  padding: 0 20px 20px 20px;
                  cursor: move;
                  /* Fade out while not hovering */
                  opacity: 0.65;
                  zoom: 0.9;
                  transition: opacity 500ms 1s;
                }
                #controls:hover {
                  /* Fade in while hovering */
                  opacity: 0.95;
                  transition-delay: 0;
                }
                #outmap { height: calc(100vh - 80px) !important; }
        "))
    ),
    # includeCSS(file.path(app_path, 'styles.css')),
    
    div(class = 'outer',
        leafletOutput('outmap'),
        absolutePanel(
            id = 'controls', 
            class = 'panel panel-default', 
            fixed = TRUE, draggable = TRUE, 
            top = 80, left = 16, right = 'auto', bottom = 'auto',
            width = 330, height = 'auto',
            virtualSelectInput(
                'cbo_', 'POSTCODE:', some.lst, character(0), search = TRUE, 
                placeholder = 'Select Postcode Unit', 
                searchPlaceholderText = 'Search...', 
                noSearchResultsText = 'No Postcode found!'
            )
        )
    )
    
)

server <- function(input, output) {

    output$out_map <- renderLeaflet({ mps})

    observe({
        leafletProxy('outmap')
        yz <- input$outmap_zoom
        if(yz >= 15){
            yz <- input$outmap_bounds
            ypx <- yp |> subset(fid %in% yd[X %between% c(yz$west, yz$east) & Y %between% c(yz$south, yz$north), fid])
            if(nrow(ypx) > 0)
                leafletProxy('outmap') |> 
                    addAwesomeMarkers(
                        data = ypx, 
                        label = ~fid, 
                        group = 'pfa', 
                        icon = makeAwesomeIcon(icon = 'hexagon', library = "fa", markerColor = 'red', iconColor = 'black')
                    )
        }
    })

}

shinyApp(ui = ui, server = server)
