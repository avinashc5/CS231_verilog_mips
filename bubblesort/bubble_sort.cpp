#include <iostream>
using namespace std;

void bubble_sort(int a[], int n){
	for (int i = n-1; i >= 0; i--){
		for (int j = 0; j < i; j++){
			if (a[j] > a[j+1]){
				swap(a[j], a[j+1]);
			}
		}
	}
}

int main(){
	int n = 9;
	int a[] = {4, 1, 5, 3, 4, 3, 1, 5, 3};
	bubble_sort(a, n);
	for (int i = 0; i < n; i++) cout << a[i] << " ";
	cout << endl;
}