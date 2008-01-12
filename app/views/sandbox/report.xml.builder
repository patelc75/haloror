xml.chart do
  xml.chart_data do
		xml.chart_type("Line")
    xml.row do
      xml.null("")
    end
    for @heartrate in @heartrates
      xml.row do
        # xml.string(@heartrate.title)
        xml.number(@heartrate.heartRate)
      end
    end
  end
end
