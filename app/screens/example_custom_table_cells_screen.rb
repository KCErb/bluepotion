# AKA a list with custom views
class ExampleCustomTableCellsScreen < PMListScreen
  stylesheet ExampleCustomTableCellsScreenStylesheet
  title "Example Custom Table Cells"

  def load_view
    mp "ExampleTableScreen load_view"
    Potion::ListView.new(self.activity)
  end

  def table_data
    [{
      title: "BluePotion Developers",
      cells: [{
        title: "I'm a Regular Cell"
      },{
        title: "Gant",
        cell_xml: R::Layout::Image_cell,
        update: :update_xml_cell,
        action: :view_developer,
        arguments: { github: "GantMan" }
      },{
        title: "Todd",
        cell_xml: R::Layout::Image_cell,
        update: :update_xml_cell,
        action: :view_developer,
        arguments: { github: "twerth" }
      }]
    }]
  end

  def view_developer(args, position)
    mp args
  end

  def update_xml_cell(cell, cell_data)
    # Let's set the cell info specific to Image_cell
    rmq_cell = find(cell)
    rmq_cell.find(Potion::Label).data = cell_data[:title]
    rmq_cell.find(Potion::ImageView).get.imageResource = rmq.image.resource("ic_launcher")
  end
end