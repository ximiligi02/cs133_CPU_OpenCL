__kernel                                            
void Kernel(__global float *Cin,                        
            __global float *weight,                        
            __global float *Cout5   )            
     
{                                                   
                                              
  // Get the work-item's unique ID
    int i = get_global_id(0);

    for (int j = 0; j < 256; j++) {

        float weight_local[5][5];
        for (int p = 0; p < 5; p++) {
            for (int q = 0; q < 5; q++) {
                weight_local[p][q] = weight[i * 6400 + j * 25 + p * 5 + q];
            }
        }

        for (int hh = 0; hh < 224; hh+= 56) {
            for (int ww = 0; ww < 224; ww+= 56) {
                float Cin_local[60][60];
                for (int h = 0; h < 60; h++) {
                    for (int w = 0; w < 60; w++) {
                        Cin_local[h][w] = Cin[j * 51984 + (hh + h) * 228 + ww + w];
                    }
                }

                for (int h = 0; h < 56; h++) {
                    for (int w = 0; w < 56; w+=4) {
                        float4 tmp4 = vload4(0, &Cout5[i * 50176 + h * 224 + w]);
                        for (int p = 0; p < 5; p++) {
                            for (int q = 0; q < 5; q++) {
                                float4 i4 = vload4(0, &Cin_local[h + p][w + q]);
                                float weight = weight_local[p][q];
                                float4 w4 = (float4) (weight, weight, weight, weight);

                                tmp4 = tmp4 + i4 * w4;
                            }
                        }
                        vstore4(tmp4, 0, &Cout5[i * 50176 + h * 224 + w]);
                    }
                }
            }
        }
        for (int h = 0; h < 224; h++) {
            for (int w = 0; w < 224; w+=4) {
                float4 tmp4 = vload4(0, &Cout5[i * 50176 + h * 224 + w]);
                for (int p = 0; p < 5; p++) {
                    for (int q = 0; q < 5; q++) {
                        float4 i4 = vload4(0, &Cin[j * 51984 + (h + p) * 228 + w + q]);
                        float weight = weight_local[p][q];
                        float4 w4 = (float4) (weight, weight, weight, weight);

                        tmp4 = tmp4 + i4 * w4;
                    }
                }
                vstore4(tmp4, 0, &Cout5[i * 50176 + h * 224 + w]);
            }
        }
    }
	
  

}                                                   
