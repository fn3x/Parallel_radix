using System;
using System.Threading;
using System.Collections.Generic;
using System.Linq;

namespace Radix_sort
{
	public class Program
	{
    static Dictionary<int, int> threadsIndices;
    static int[] initialArray;
    static int numOfThreads = 8;
    static void Main(string[] args)
    {
      int Min = 0;
      int Max = 1000;
      int sizeOfArray = 100000;
      initialArray = new int[sizeOfArray];

      generateArray(Min, Max, sizeOfArray);

      int maxNum = findMaxNum();

      calculateIndicesForThreads();

      var watch = System.Diagnostics.Stopwatch.StartNew();
      radixParallel(maxNum, sizeOfArray);
      // radixSequence(initialArray, sizeOfArray, maxNum);
      var elapsedMs = watch.ElapsedMilliseconds;

      Console.WriteLine("Elapsed time: " + elapsedMs.ToString() + "ms");
    }
    static int findMaxNum()
    {
      return initialArray.Max();
    }
    static void generateArray(int Min, int Max, int sizeOfArray)
    {
      Random randNum = new Random();
      for (int i = 0; i < sizeOfArray; i++)
      {
        initialArray[i] = randNum.Next(Min, Max);
      }
    }
    static void radixParallel(int maxNum, int sizeOfArray)
    {
      var list = new List<int>(numOfThreads);
      for (var i = 0; i < numOfThreads; i++) list.Add(i);
      for (int rank = 1; maxNum / rank > 0; rank *= 10)
      {
        using (var countdownEvent = new CountdownEvent(numOfThreads))
        {
          int i = 0;
          foreach (var indicesPair in threadsIndices)
          {
            ThreadPool.QueueUserWorkItem(state =>
            {
              countingsort(indicesPair.Key, indicesPair.Value, rank);
              countdownEvent.Signal();
            }, list[i]);

            i++;
          }

          countdownEvent.Wait();
          reorderBuckets(rank, sizeOfArray);
        }
      }
    }
    static void calculateIndicesForThreads()
    {
      threadsIndices = new Dictionary<int, int>();
      var len = (int)initialArray.Length / numOfThreads;
      int iterator = 0;
      int numRemaining = initialArray.Length - len * numOfThreads;

      for (int i = 0; i < numOfThreads; i++)
      {
        if (numRemaining > 0)
        {
          threadsIndices[iterator] = iterator + len + 1;
          iterator += len + 1;
          numRemaining--;
        }
        else
        {
          threadsIndices[iterator] = iterator + len;
          iterator += len;
        }
      }
    }
    static void countingsort(int startIndex, int endIndex, int place)
    {
      int[] output = new int[endIndex - startIndex];

      //range of the number is 0-9 for each place considered.
      int[] freq = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
      //count number of occurrences in freq array
      for (int i = startIndex; i < endIndex; i++)
      {
        freq[(initialArray[i] / place) % 10]++;
      }

      //Change count[i] so that count[i] now contains actual 
      //position of this digit in output[] 
      for (int i = 1; i < 10; i++)
      {
        freq[i] += freq[i - 1];
      }

      //Build the output array 
      for (int i = endIndex - 1; i >= startIndex; i--)
      {
        output[freq[(initialArray[i] / place) % 10] - 1] = initialArray[i];
        freq[(initialArray[i] / place) % 10]--;
      }

      //Copy the output array to the input Array, Now the Array will 
      //contain sorted array based on digit at specified place
      for (int i = startIndex; i < endIndex; i++)
        initialArray[i] = output[i - startIndex];

    }
    static int getDigitInNumberByRank(int number, int rank)
    {
      int counter = 1;

      while (number > 0 && rank != counter)
      {
        number = number / 10;
        counter *= 10;
      }

      return number % 10;
    }
    static void reorderBuckets(int rank, int sizeOfArray)
    {
      int pos = 0;
      for (int i = 0; i < 10; i++)
      {
        for (int j = 0; j < sizeOfArray; j++)
        {
          int currentNumber = Array[j];

          if (getDigitInNumberByRank(currentNumber, rank) == i)
          {
            Array[j] = Array[pos];
            Array[pos] = currentNumber;
            pos++;
          }
        }
      }
    }
    static void PrintArray()
    {
      int n = initialArray.Length;
      for (int i = 0; i < n; i++)
        Console.Write(initialArray[i] + " ");
      Console.Write("\n\n");
    }
    public static void countSort(int[] arr, int n, int exp)
    {
      int[] output = new int[n]; // output array
      int i;
      int[] count = new int[10];

      // initializing all elements of count to 0
      for (i = 0; i < 10; i++)
        count[i] = 0;

      // Store count of occurrences in count[]
      for (i = 0; i < n; i++)
        count[(arr[i] / exp) % 10]++;

      // Change count[i] so that count[i] now contains
      // actual
      //  position of this digit in output[]
      for (i = 1; i < 10; i++)
        count[i] += count[i - 1];

      // Build the output array
      for (i = n - 1; i >= 0; i--)
      {
        output[count[(arr[i] / exp) % 10] - 1] = arr[i];
        count[(arr[i] / exp) % 10]--;
      }

      // Copy the output array to arr[], so that arr[] now
      // contains sorted numbers according to current
      // digit
      for (i = 0; i < n; i++)
        arr[i] = output[i];
    }
    public static void radixSequence(int[] arr, int n, int max)
    {
      for (int exp = 1; max / exp > 0; exp *= 10)
        countSort(arr, n, exp);
    }
	}
}
