extern int MIN_2(int x, int y);

int main(){
	int a[5] = {256, 128, 64,10, 16}; // list for search
	int i;
	int min_val = a[0];
	for (i = 1; i<5; i++){
		min_val = MIN_2(a[i],min_val); // Call subroutine from assembly
	}
	return min_val;
}
