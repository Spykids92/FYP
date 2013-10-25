json.array!(@generators) do |generator|
  json.extract! generator, :primer_length, :random_primer_generated
  json.url generator_url(generator, format: :json)
end
