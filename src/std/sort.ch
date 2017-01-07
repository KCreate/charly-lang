const Math = require("math")

/*
 * Adapted from https://gist.github.com/paullewis/1981455
 * */
const Quicksort = {

  /*
   * Swaps two values of an array
   *
   * @param Numeric indexA Index of the first item
   * @param Numeric indexB Index of the second item
   * */
  func swap(array, indexA, indexB) {
    const tmp = array[indexA]
    array[indexA] = array[indexB]
    array[indexB] = tmp
  }

  /*
   * Partitions an array into values less than and greater
   * than the pivot value
   *
   * @param Array array The target array
   * @param Numeric pivot The index of the pivot
   * @param Numeric left The index of the leftmost element
   * @param Numeric right The index of the rightmost element
   * @return Array Array containing two other array representing each side
   * */
  func partition(array, pivot, left, right) {
    let store_index = left
    let pivot_value = array[pivot]

    // put the pivot on the right
    Quicksort.swap(array, pivot, right)

    // go through the rest
    left.upto(right, ->(index) {

      /*
       * If the value is less than the pivot's
       * value put it to the left of the pivot
       * point and move the pivot point along one
       * */
      if array[index] < pivot_value {
        Quicksort.swap(array, index, store_index)
        store_index += 1
      }
    })

    Quicksort.swap(array, right, store_index)

    return store_index
  }

  /*
   * Sorts the array
   *
   * @param Array array The target array
   * @param Numeric left The index of the leftmost element, defaults 0
   * @param Numeric right The index of the rightmost element, defaults array.length() - 1
   * @return Array The sorted array
   * */
  func sort(array) {
    let pivot
    let left = arguments[1]
    let right = arguments[2]

    if left.typeof() ! "Numeric" {
      left = 0
    }

    if right.typeof() ! "Numeric" {
      right = array.length() - 1
    }

    if left < right {
      pivot = left + Math.ceil((right - left) * 0.5)
      pivot = Quicksort.partition(array, pivot, left, right)

      Quicksort.sort(array, left, pivot - 1)
      Quicksort.sort(array, pivot + 1, right)
    }
  }
}

const Bubblesort = {

  /*
   * Sorts an array (in-place)
   *
   * @param Array array The array to sort
   * @return Array array The sorted array
   * */
  func sort(array) {
    let left
    let right
    let size = array.length()

    size.times(->(lp) {
      (size - 1).times(->(rp) {

        left = array[lp]
        right = array[rp]

        if left < right {
          array[lp] = right
          array[rp] = left
        }
      })
    })

    array
  }
}

export.Quicksort = Quicksort.sort
export.Bubblesort = Bubblesort.sort
