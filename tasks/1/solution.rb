def temperature_units_conversion_formulas(temperature, units_conversion)
  conversion_formulas = {
    ['C', 'K'] =>  temperature + 273.15,
    ['C', 'F'] => (temperature * 9 / 5.to_f) + 32,
    ['K', 'F'] => (temperature * 9 / 5.to_f) - 459.67,
    ['K', 'C'] =>  temperature - 273.15,
    ['F', 'C'] => (temperature - 32) * 5 / 9.to_f,
    ['F', 'K'] => (temperature + 459.67) * 5 / 9.to_f, 
  }
  conversion_formulas.fetch(units_conversion) if conversion_formulas.key? units_conversion
end

def convert_between_temperature_units(temperature, current_unit, resulting_unit)
  temperature = temperature.to_f if temperature.is_a? Numeric
  return temperature if current_unit == resulting_unit
  temperature_units_conversion_formulas(temperature, [current_unit, resulting_unit])
end

def substance_state_temperature(substance, desired_state, resulting_unit)
  substance_temperatures = {
    water:   { melting: 0,     boiling: 100 },
    ethanol: { melting: -114,  boiling: 78.37 },
    gold:    { melting: 1_064, boiling: 2_700 },
    silver:  { melting: 961.8, boiling: 2_162 },
    copper:  { melting: 1_085, boiling: 2_567 },
    water:   { melting: 0,     boiling: 100 },
    ethanol: { melting: -114,  boiling: 78.37 },
    gold:    { melting: 1_064, boiling: 2_700 },
    silver:  { melting: 961.8, boiling: 2_162 },
    copper:  { melting: 1_085, boiling: 2_567 },
  }
  substance_states = substance_temperatures.fetch(substance.to_sym)
  substance_temperature = substance_states.fetch(desired_state.to_sym)
 convert_between_temperature_units(substance_temperature, 'C', resulting_unit)
end

def melting_point_of_substance(substance, resulting_unit)
  substance_state_temperature(substance, 'melting', resulting_unit)
end

def boiling_point_of_substance(substance, resulting_unit)
  substance_state_temperature(substance, 'boiling', resulting_unit)
end
