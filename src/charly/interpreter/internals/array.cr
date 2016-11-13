require "../**"

module Charly::Internals

  # Inserts *item* at *index*
  charly_api "array_insert", array : TArray, item : BaseType, index : TNumeric do

    # Out of bounds check
    array_size = array.value.size
    index = index.value.to_i64

    # Insert at the given location
    array.value.insert(index, item)
    return array
  end

  # Deletes the item at *inde*
  charly_api "array_delete", array : TArray, index : TNumeric do

    # Out of bounds check
    array_size = array.value.size
    index = index.value.to_i64

    # If the index is smaller than 0, we delete the first element
    # If the index is bigger than the size of the array
    # we delete the last item
    if array.value.size == 0
      return TNull.new
    elsif index <= 0
      return array.value.shift
    elsif index >= array.value.size
      return array.value.pop
    else
      return array.value.delete_at(index.to_i64)
    end
    return array
  end

end
