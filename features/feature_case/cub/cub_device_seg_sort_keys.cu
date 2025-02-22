#include <cub/cub.cuh>
#include <initializer_list>
#include <stdio.h>
#include <vector>

template <typename T> T *init(std::initializer_list<T> list) {
  T *arr = nullptr;
  cudaMalloc(&arr, sizeof(T) * list.size());
  cudaMemcpy(arr, list.begin(), sizeof(T) * list.size(),
             cudaMemcpyHostToDevice);
  return arr;
}

bool test() {
  // clang-format off
  
  int  num_items          = 7;
  int  num_segments       = 3;
  int  *d_offsets         = init({0, 3, 3, 7});
  int  *d_keys_in         = init({8, 6, 7, 5, 3, 0, 9});
  int  *d_keys_out        = init({0, 0, 0, 0, 0, 0, 0});
  
  std::vector<int> expected_keys_out{6, 7, 8, 0, 3, 5, 9};
  std::vector<int> expected_values_out{1, 2, 0, 5, 4, 3, 6};
  // clang-format on

  void *d_temp_storage = NULL;
  size_t temp_storage_bytes = 0;
  cub::DeviceSegmentedSort::SortKeys(d_temp_storage, temp_storage_bytes,
                                     d_keys_in, d_keys_out, num_items,
                                     num_segments, d_offsets, d_offsets + 1);

  cudaMalloc(&d_temp_storage, temp_storage_bytes);

  cub::DeviceSegmentedSort::SortKeys(d_temp_storage, temp_storage_bytes,
                                     d_keys_in, d_keys_out, num_items,
                                     num_segments, d_offsets, d_offsets + 1);

  std::vector<int> keys_out(num_items), values_out(num_items);
  cudaMemcpy(keys_out.data(), d_keys_out, sizeof(int) * num_items,
             cudaMemcpyDeviceToHost);
  
  cudaFree(d_offsets);
  cudaFree(d_keys_in);
  cudaFree(d_keys_out);
  cudaFree(d_temp_storage);
  return std::equal(keys_out.begin(), keys_out.end(),
                    expected_keys_out.begin());
}

bool test2() {
  // clang-format off
  
  int  num_items          = 7;
  int  num_segments       = 3;
  int  *d_offsets         = init({0, 3, 3, 7});
  int  *d_keys_in         = init({8, 6, 7, 5, 3, 0, 9});
  int  *d_keys_out        = init({0, 0, 0, 0, 0, 0, 0});
  
  std::vector<int> expected_keys_out{6, 7, 8, 0, 3, 5, 9};
  std::vector<int> expected_values_out{1, 2, 0, 5, 4, 3, 6};
  // clang-format on
  cudaStream_t s;
  cudaStreamCreate(&s);

  void *d_temp_storage = NULL;
  size_t temp_storage_bytes = 0;
  cub::DeviceSegmentedSort::SortKeys(d_temp_storage, temp_storage_bytes,
                                     d_keys_in, d_keys_out, num_items,
                                     num_segments, d_offsets, d_offsets + 1, s);

  cudaMalloc(&d_temp_storage, temp_storage_bytes);

  cub::DeviceSegmentedSort::SortKeys(d_temp_storage, temp_storage_bytes,
                                     d_keys_in, d_keys_out, num_items,
                                     num_segments, d_offsets, d_offsets + 1, s);

  std::vector<int> keys_out(num_items), values_out(num_items);
  cudaMemcpy(keys_out.data(), d_keys_out, sizeof(int) * num_items,
             cudaMemcpyDeviceToHost);
  
  cudaFree(d_offsets);
  cudaFree(d_keys_in);
  cudaFree(d_keys_out);
  cudaFree(d_temp_storage);
  cudaStreamDestroy(s);

  return std::equal(keys_out.begin(), keys_out.end(),
                    expected_keys_out.begin());
}

bool test_descending() {
  // clang-format off
  
  int  num_items          = 7;
  int  num_segments       = 3;
  int  *d_offsets         = init({0, 3, 3, 7});
  int  *d_keys_in         = init({8, 6, 7, 5, 3, 0, 9});
  int  *d_keys_out        = init({0, 0, 0, 0, 0, 0, 0});
  
  std::vector<int> expected_keys_out{8, 7, 6, 9, 5, 3, 0};
  
  // clang-format on

  void *d_temp_storage = NULL;
  size_t temp_storage_bytes = 0;
  cub::DeviceSegmentedSort::SortKeysDescending(
      d_temp_storage, temp_storage_bytes, d_keys_in, d_keys_out, num_items,
      num_segments, d_offsets, d_offsets + 1);

  cudaMalloc(&d_temp_storage, temp_storage_bytes);

  cub::DeviceSegmentedSort::SortKeysDescending(
      d_temp_storage, temp_storage_bytes, d_keys_in, d_keys_out, num_items,
      num_segments, d_offsets, d_offsets + 1);

  std::vector<int> keys_out(num_items), values_out(num_items);
  cudaMemcpy(keys_out.data(), d_keys_out, sizeof(int) * num_items,
             cudaMemcpyDeviceToHost);
  
  cudaFree(d_offsets);
  cudaFree(d_keys_in);
  cudaFree(d_keys_out);
  cudaFree(d_temp_storage);
  return std::equal(keys_out.begin(), keys_out.end(),
                    expected_keys_out.begin());
}

bool test_descending2() {
  // clang-format off
  
  int  num_items          = 7;
  int  num_segments       = 3;
  int  *d_offsets         = init({0, 3, 3, 7});
  int  *d_keys_in         = init({8, 6, 7, 5, 3, 0, 9});
  int  *d_keys_out        = init({0, 0, 0, 0, 0, 0, 0});
  
  std::vector<int> expected_keys_out{8, 7, 6, 9, 5, 3, 0};
  
  // clang-format on
  cudaStream_t s;
  cudaStreamCreate(&s);

  void *d_temp_storage = NULL;
  size_t temp_storage_bytes = 0;
  cub::DeviceSegmentedSort::SortKeysDescending(
      d_temp_storage, temp_storage_bytes, d_keys_in, d_keys_out, num_items,
      num_segments, d_offsets, d_offsets + 1, s);

  cudaMalloc(&d_temp_storage, temp_storage_bytes);

  cub::DeviceSegmentedSort::SortKeysDescending(
      d_temp_storage, temp_storage_bytes, d_keys_in, d_keys_out, num_items,
      num_segments, d_offsets, d_offsets + 1, s);

  std::vector<int> keys_out(num_items), values_out(num_items);
  cudaMemcpy(keys_out.data(), d_keys_out, sizeof(int) * num_items,
             cudaMemcpyDeviceToHost);
  
  cudaFree(d_offsets);
  cudaFree(d_keys_in);
  cudaFree(d_keys_out);
  cudaFree(d_temp_storage);
  cudaStreamDestroy(s);

  return std::equal(keys_out.begin(), keys_out.end(),
                    expected_keys_out.begin());
}

bool test_double_buffer() {
  // clang-format off
  
  int  num_items          = 7;
  int  num_segments       = 3;
  int  *d_offsets         = init({0, 3, 3, 7});
  int  *d_keys_in         = init({8, 6, 7, 5, 3, 0, 9});
  int  *d_keys_out        = init({0, 0, 0, 0, 0, 0, 0});
  
  cub::DoubleBuffer<int> d_keys(d_keys_in, d_keys_out);
  
  std::vector<int> expected_keys_out{6, 7, 8, 0, 3, 5, 9};
  std::vector<int> expected_values_out{1, 2, 0, 5, 4, 3, 6};
  // clang-format on

  void *d_temp_storage = NULL;
  size_t temp_storage_bytes = 0;
  cub::DeviceSegmentedSort::SortKeys(d_temp_storage, temp_storage_bytes, d_keys,
                                     num_items, num_segments, d_offsets,
                                     d_offsets + 1);

  cudaMalloc(&d_temp_storage, temp_storage_bytes);

  cub::DeviceSegmentedSort::SortKeys(d_temp_storage, temp_storage_bytes, d_keys,
                                     num_items, num_segments, d_offsets,
                                     d_offsets + 1);

  std::vector<int> keys_out(num_items), values_out(num_items);
  cudaMemcpy(keys_out.data(), d_keys.Current(), sizeof(int) * num_items,
             cudaMemcpyDeviceToHost);
  
  cudaFree(d_offsets);
  cudaFree(d_keys_in);
  cudaFree(d_keys_out);
  cudaFree(d_temp_storage);
  return std::equal(keys_out.begin(), keys_out.end(),
                    expected_keys_out.begin());
}

bool test_double_buffer2() {
  // clang-format off
  
  int  num_items          = 7;
  int  num_segments       = 3;
  int  *d_offsets         = init({0, 3, 3, 7});
  int  *d_keys_in         = init({8, 6, 7, 5, 3, 0, 9});
  int  *d_keys_out        = init({0, 0, 0, 0, 0, 0, 0});
  
  cub::DoubleBuffer<int> d_keys(d_keys_in, d_keys_out);
  
  std::vector<int> expected_keys_out{6, 7, 8, 0, 3, 5, 9};
  std::vector<int> expected_values_out{1, 2, 0, 5, 4, 3, 6};
  // clang-format on
  cudaStream_t s;
  cudaStreamCreate(&s);

  void *d_temp_storage = NULL;
  size_t temp_storage_bytes = 0;
  cub::DeviceSegmentedSort::SortKeys(d_temp_storage, temp_storage_bytes, d_keys,
                                     num_items, num_segments, d_offsets,
                                     d_offsets + 1, s);

  cudaMalloc(&d_temp_storage, temp_storage_bytes);

  cub::DeviceSegmentedSort::SortKeys(d_temp_storage, temp_storage_bytes, d_keys,
                                     num_items, num_segments, d_offsets,
                                     d_offsets + 1, s);

  std::vector<int> keys_out(num_items), values_out(num_items);
  cudaMemcpy(keys_out.data(), d_keys.Current(), sizeof(int) * num_items,
             cudaMemcpyDeviceToHost);
  
  cudaFree(d_offsets);
  cudaFree(d_keys_in);
  cudaFree(d_keys_out);
  cudaFree(d_temp_storage);
  cudaStreamDestroy(s);

  return std::equal(keys_out.begin(), keys_out.end(),
                    expected_keys_out.begin());
}

bool test_double_buffer_descending() {
  // clang-format off
  
  int  num_items          = 7;
  int  num_segments       = 3;
  int  *d_offsets         = init({0, 3, 3, 7});
  int  *d_keys_in         = init({8, 6, 7, 5, 3, 0, 9});
  int  *d_keys_out        = init({0, 0, 0, 0, 0, 0, 0});
  
  cub::DoubleBuffer<int> d_keys(d_keys_in, d_keys_out);
  
  std::vector<int> expected_keys_out{8, 7, 6, 9, 5, 3, 0};
  
  // clang-format on

  void *d_temp_storage = NULL;
  size_t temp_storage_bytes = 0;
  cub::DeviceSegmentedSort::SortKeysDescending(
      d_temp_storage, temp_storage_bytes, d_keys, num_items, num_segments,
      d_offsets, d_offsets + 1);

  cudaMalloc(&d_temp_storage, temp_storage_bytes);

  cub::DeviceSegmentedSort::SortKeysDescending(
      d_temp_storage, temp_storage_bytes, d_keys, num_items, num_segments,
      d_offsets, d_offsets + 1);

  std::vector<int> keys_out(num_items), values_out(num_items);
  cudaMemcpy(keys_out.data(), d_keys.Current(), sizeof(int) * num_items,
             cudaMemcpyDeviceToHost);
  
  cudaFree(d_offsets);
  cudaFree(d_keys_in);
  cudaFree(d_keys_out);
  cudaFree(d_temp_storage);
  return std::equal(keys_out.begin(), keys_out.end(),
                    expected_keys_out.begin());
}

bool test_double_buffer_descending2() {
  // clang-format off
  
  int  num_items          = 7;
  int  num_segments       = 3;
  int  *d_offsets         = init({0, 3, 3, 7});
  int  *d_keys_in         = init({8, 6, 7, 5, 3, 0, 9});
  int  *d_keys_out        = init({0, 0, 0, 0, 0, 0, 0});
  
  cub::DoubleBuffer<int> d_keys(d_keys_in, d_keys_out);
  
  std::vector<int> expected_keys_out{8, 7, 6, 9, 5, 3, 0};
  
  // clang-format on
  cudaStream_t s;
  cudaStreamCreate(&s);

  void *d_temp_storage = NULL;
  size_t temp_storage_bytes = 0;
  cub::DeviceSegmentedSort::SortKeysDescending(
      d_temp_storage, temp_storage_bytes, d_keys, num_items, num_segments,
      d_offsets, d_offsets + 1, s);

  cudaMalloc(&d_temp_storage, temp_storage_bytes);

  cub::DeviceSegmentedSort::SortKeysDescending(
      d_temp_storage, temp_storage_bytes, d_keys, num_items, num_segments,
      d_offsets, d_offsets + 1, s);

  std::vector<int> keys_out(num_items), values_out(num_items);
  cudaMemcpy(keys_out.data(), d_keys.Current(), sizeof(int) * num_items,
             cudaMemcpyDeviceToHost);
  
  cudaFree(d_offsets);
  cudaFree(d_keys_in);
  cudaFree(d_keys_out);
  cudaFree(d_temp_storage);
  cudaStreamDestroy(s);

  return std::equal(keys_out.begin(), keys_out.end(),
                    expected_keys_out.begin());
}

int main() {
  int res = 0;
  if (!test()) {
    printf("cub::DeviceSegmentedSort::SortKeys failed\n");
    res = 1;
  }
  if (!test2()) {
    printf("cub::DeviceSegmentedSort::SortKeys failed\n");
    res = 1;
  }

  if (!test_descending()) {
    printf("cub::DeviceSegmentedSort::SortKeysDescending failed\n");
    res = 1;
  }

  if (!test_descending2()) {
    printf("cub::DeviceSegmentedSort::SortKeysDescending failed\n");
    res = 1;
  }

  if (!test_double_buffer()) {
    printf("cub::DeviceSegmentedSort::SortKeys (DoubleBuffer) failed\n");
    res = 1;
  }

  if (!test_double_buffer2()) {
    printf("cub::DeviceSegmentedSort::SortKeys (DoubleBuffer) failed\n");
    res = 1;
  }

  if (!test_double_buffer_descending()) {
    printf(
        "cub::DeviceSegmentedSort::SortKeysDescending (DoubleBuffer) failed\n");
    res = 1;
  }

  if (!test_double_buffer_descending2()) {
    printf(
        "cub::DeviceSegmentedSort::SortKeysDescending (DoubleBuffer) failed\n");
    res = 1;
  }

  return res;
}
