<?php
	$newobj = new Mcalc();
	$newobj->connect();
	class Mcalc{
		public $nperiods;
		public $years = array();
		public $variable_names = array();
		public $valid = array();
		public $sign = array();
		public $Xsmooth = array();
		public $alpha = 1;
		function connect() {
			// MAKE DB CONNECTION
			//$credentials = new Zend_Config_Ini("configs/webconfig.ini", "db");
			$host = "localhost";
			$uid = "root";
			$pwd = "";
			$mysqldb = mysql_connect($host,$uid,$pwd);
			if (!$mysqldb) return array("error"=>"could not connect to mysql server");
			if (!mysql_select_db($credentials->mysql->db,$mysqldb)) return array("error"=>"could not select db");
			return true;
		}
		function solve($issues,$from,$to) {
			foreach ($issues as $varname=>$issue) {
				if (!in_array($varname,$this->variable_names)) {
					$this->variable_names[] = $varname;
				}
				for($year=$from;$year<=$to;$year++) {
					$pIssue[$year][$varname] = $issue[$year];
				}
			}
			$this->years = array_keys($pIssue);
			$this->nperiods = count($this->years);
			foreach ($this->variable_names as $v) { // Z-score loop
				$nGood=0;
				$s=0;
				for($p=$from;$p<=$to;$p++) { // For average
					if(!empty($pIssue[$p][$v])) {
						$nGood++;
						$s += $pIssue[$p][$v];
					}
				}
				$varCases[$v]=$nGood;
				$av[$v]=$s/$nGood;
				$varStd[$v]=$this->fStdev($pIssue,$v); // * double(nGood-1)/nGood;  //population s.d.
				for($p=$from;$p<=$to;$p++) {
					if(!empty($pIssue[$p][$v])) {
						$pIssue[$p][$v]=100+10*($pIssue[$p][$v]-$av[$v])/$varStd[$v];
					}
				}
				$this->valid[$v]=1; //initial values
				$this->sign[$v]=1;
				$oldr[$v]=1;
			}  //end v
			$iter = 0;
			$tola = .001;
			$converge = 0;
			$lastconv = 99;
			$log_txt = "Period: ".$from." to ".$to." ".$this->nperiods." Time Points\r\n\r\n";
			//$log_txt .= "Number of Series:".."\r\n";
			$log_txt .= "Iter\tConverge\tCrit\tReliability\tAlphaF\tAlphaB\r\n";
			$log_txt .= "-----------------------------------------------------------------------\r\n";
			while($iter==0||$converge > $tola) {//master iteration control loop
				// dyad ratios
				$mood = $this->dyad_ratios($pIssue);
				//calculate average mood
				foreach ($this->years as $year_index) {
					$mood_average[$year_index] = ($mood["forward"][$year_index] + $mood["backward"][$year_index]) / 2;
				}
				$iter++; //increment iteration count
				$corr = $this->isCorr($pIssue,$mood_average);
				$converge=0;$wtmean=0;$wtstd=0;$vsum=0;$evalue=0;$totalvar=0;
				foreach ($this->variable_names as $v) {
					$wn=0;
					for($p=$from;$p<=$to;$p++) {
						if(!empty($pIssue[$p][$v])) {
							$wn++; // how many years have values for this variable?
						}
					}
					$vratio = 0;
					$vratio = $wn/$this->nperiods;
					$evalue += $vratio * $corr[$v]*$corr[$v];
					$totalvar += $vratio;
					//convergence tests
					if($wn>3) {
						// largest $corr[$v] should equal 1.18 or .82??? nope
						$conv=abs($corr[$v]-$oldr[$v]);  //conv is convergence test for item v
						$conv=$conv * $wn/$this->nperiods; //weighted by periods
						if($conv>$converge) $converge=$conv;  //CONVERGE IS MAX(CONV)
					}
					//if(corr[v]!=99)  // current function doesn't assign 99!
					//{
						$oldr[$v]=$corr[$v];
						$this->valid[$v]=$corr[$v]*$corr[$v];
					//}
					$wtmean += $av[$v] * $this->valid[$v];
					$wtstd += $varStd[$v] * $this->valid[$v];
					$vsum += $this->valid[$v];
				} //v
				if($vsum > 0) {
					$wtmean=$wtmean/$vsum;
					$wtstd=$wtstd/$vsum;
				}
				$mean1=$wtmean;
				$std1=$wtstd;
				$e1=$evalue;
				// reliability??
				$fbCorr=$this->fbCor($mood,$from,$to);
				//output convergence results here
				//$outRec[$iter]["iter"]=$iter;
				//$outRec[$iter]["converge"]=$converge;
				//$outRec[$iter]["tola"]=$tola;
				//$outRec[$iter]["rely"]=$fbCorr;
				//$outRec[$iter]["alphaF"]=$this->alphaF;
				//$outRec[$iter]["alphaB"]=$this->alpha;
				$log_txt .= $iter."\t";
				$log_txt .= number_format($converge,5)."\t\t";
				$log_txt .= number_format($tola,3)."\t";
				$log_txt .= number_format($fbCorr,3)."\t\t";
				$log_txt .= number_format($this->alphaF,3)."\t";
				$log_txt .= number_format($this->alpha,3)."\r\n";
				if($converge > $lastconv) {
					//echo $converge."<-->".$lastconv;
					$tola=$tola * 2;
				}
				$lastconv=$converge;
				if($iter > 50) {
					break;
				}  //emergency shut down of while loop
			} // end iteration control loop
			$corr = $this->isCorr($pIssue,$mood_average); // compute final loadings
			$expprop=($evalue/$totalvar)*100;     //exp relative
			$msum=0;
			$msq=0;
			foreach ($this->years as $year_index) {
				$mfbp = $mood_average[$year_index];
				$msum += $mfbp;
				$msq += $mfbp*$mfbp;
			}
			$moodMean=$msum/$this->nperiods;
			$sdMood= sqrt(($msq/$this->nperiods)-$moodMean*$moodMean);
			//now weighted average metric
			foreach ($this->years as $year_index) {
				$mood_average[$year_index]=(($mood_average[$year_index] - $moodMean)*$wtstd/$sdMood)+$wtmean;
			}
			$log_txt .= "\r\nVariable\tCases\tDim1 Loading\tMean\t\tStd Deviation\r\n";
			$log_txt .= "-----------------------------------------------------------------------\r\n";
			foreach ($this->variable_names as $v) {
				$log_txt .= str_pad($v,9)."\t".$varCases[$v]."\t".number_format($corr[$v],3)."\t\t".number_format($av[$v],3)."\t\t".number_format($varStd[$v],3)."\r\n";
			}
			$log_txt .= "\r\nEigen Estimate ".number_format($evalue,2)." of possible ".number_format($totalvar,2)."\r\n";
			$log_txt .= "Variance explained: ".number_format($expprop,2)."%\r\n";
			$log_txt .= "\r\nMean:\t\t".number_format($wtmean,2)."\r\nStd Deviation:\t".number_format($wtstd,2)."\r\n";
			$outRec[] = $log_txt;
			$outRec[] = $mood_average;
			/*
			echo "<pre>";
			print_r($mood_average);
			echo $log_txt;
			echo "</pre>";
			die();
			*/
			return $outRec;
		}
		function dyad_ratios($data,$smoothing=true) {
			$mood["forward"] = array();
			$mood["backward"] = array();
			// FORWARD
			$this->alpha=1;
			$this->alphaF=1;
			$mood_forward[$this->years[0]]=100;  //pmood[rp+startper-1]=100;
			$firstj=2;
			$lastj=count($this->years);
			$cd=$lastj-$firstj+1;  //countdown variable
			$jprev=1;
			$j = $firstj;
			//echo "FORWARD<br>";
			while ($cd>0) {
				$cd --;
				$year = $this->years[$j-1];
				$variables = $data[$this->years[$j-1]];
				$mood_forward[$year] = 0;
				$everlap = 0;
				$firstj2=1;
				$lastj2=$j-1;
				for ($j2 = $firstj2; $j2 <= $lastj2; $j2++) {
					$compare_year = $this->years[$j2-1];
					$compare_variables = $data[$this->years[$j2-1]];
					$sum=0;
					$consum=0;  //sum of communalities across issues  //ACROSS??
					$overlap=0;
					foreach ($this->variable_names as $v) {
						$xj = $variables[$v]; //base year value
						$sngx2 = $compare_variables[$v]; //comparison year value
						if(!empty($xj) && !empty($sngx2)) {
							$overlap = $overlap + 1;               //numb of issues contributing to sum
							$ratio = $xj / $sngx2;
							if ($this->sign[$v] < 0) {
								//echo "flipped it";
								$ratio = 1 / $ratio;
							}
							$sum += $this->valid[$v] * $ratio * $mood_forward[$compare_year];
							$consum += $this->valid[$v];
						}
					}
					if($overlap > 0) {
						$everlap= $everlap + 1;
						$mood_forward[$year] += $sum / $consum;
					};
				}
				if ($everlap > 0) {
					$mood_forward[$year] = $mood_forward[$year] / $everlap;
				} else {
					$mood_forward[$year] = $mood_forward[$this->years[$jprev-1]];
				}
				$jprev = $j;
				$j ++;
			}
			// SMOOTHING FORWARD
			if ($smoothing) {
				$this->alpha = $this->esmooth($mood_forward,$this->alpha);     //NOW SMOOTH USING ALPHA
				for($tm=0;$tm<$this->nperiods-1;$tm++) {
					$fVectSm[$tm]=$mood_forward[$this->years[$tm]];
				}
				for($tm=1;$tm<=$this->nperiods-1;$tm++) {
					$fVectSm[$tm]= $this->alpha*$mood_forward[$this->years[$tm]]+(1-$this->alpha)*$fVectSm[$tm-1];
				};
				for($tm=0;$tm<=$this->nperiods-1;$tm++) {
					$mood_forward[$this->years[$tm]]=$fVectSm[$tm];
				}
			}
			// END FORWARD
			// BACKWARD
			$this->alphaF=$this->alpha;
			$mood_backward[$this->years[$this->nperiods-1]] = $mood_forward[$this->years[$this->nperiods-1]];
			$firstj=$this->nperiods-1;
			$lastj=1;
			$cd=$firstj-$lastj+1;
			$jprev=$this->nperiods;
			$j = $firstj;
			while ($cd>0) {
				$cd --;
				$year = $this->years[$j-1];
				$variables = $data[$this->years[$j-1]];
				$mood_backward[$year] = 0;
				$everlap = 0;
				$firstj2=$j+1;
				$lastj2=$this->nperiods;
				for ($j2 = $firstj2; $j2 <= $lastj2; $j2++) {
					$compare_year = $this->years[$j2-1];
					$compare_variables = $data[$this->years[$j2-1]];
					$sum=0;
					$consum=0;  //sum of communalities across issues
					$overlap=0;
					foreach ($this->variable_names as $v) {
							$xj = $variables[$v];                    //base year value
							$sngx2 = $compare_variables[$v];    //comparison year value
							if(!empty($xj) && !empty($sngx2)) {
								$overlap = overlap + 1;               //numb of issues contributing to sum
								$ratio = $xj / $sngx2;
								if ($this->sign[$v] < 0) {
									$ratio = 1 / $ratio;
								}
								$sum += $this->valid[$v] * $ratio * $mood_backward[$this->years[$j2-1]];
								$consum += $this->valid[$v];
							}
					}
					if($overlap > 0) {
						$everlap= $everlap + 1;
						$mood_backward[$year] += $sum / $consum;
					};
				}
				if ($everlap > 0) {
					$mood_backward[$year] = $mood_backward[$year] / $everlap;
				} else {
					$mood_backward[$year] = $mood_backward[$this->years[$jprev-1]];
				}
				$jprev = $j;
				$j --;
			}
			// SMOOTHING BACKWARD
			if ($smoothing) {
				$this->alpha = $this->esmooth($mood_backward,$this->alpha);     //NOW SMOOTH USING ALPHA
				for($tm=0;$tm<$this->nperiods-1;$tm++) {
					$fVectSm[$tm]=$mood_backward[$this->years[$tm]];
				}
				for($tm=1;$tm<=$this->nperiods-1;$tm++) {
					$fVectSm[$tm]= $this->alpha*$mood_backward[$this->years[$tm]]+(1-$this->alpha)*$fVectSm[$tm-1];
				};
				for($tm=0;$tm<=$this->nperiods-1;$tm++) {
					$mood_backward[$this->years[$tm]]=$fVectSm[$tm];
				}
			}
			$mood = array("forward"=>$mood_forward,"backward"=>$mood_backward);
			return $mood;
		}
		// Purpose: calculate standard deviation
		function fStdev($pIssue,$v) { //does stdev for *pIssue only    divides by N
			$s=0;
			$n=$this->nperiods;
			$nGood=0;  //n local, nperiods global
			for($j=1;$j<=$n;$j++) {
				if(!empty($pIssue[$this->years[$j-1]][$v])) {
					$nGood++;
					$s += $pIssue[$this->years[$j-1]][$v];
				}
			}
			$ave=$s/$nGood;  //mean
			$s=0;
			for($j=1;$j<=$n;$j++) {
				if(!empty($pIssue[$this->years[$j-1]][$v])) {
					$dev = $pIssue[$this->years[$j-1]][$v]-$ave;
					$s += $dev*$dev;
				}
			}
			$var=$s/$nGood;  //sigma squared
			$sdev=sqrt($var);
			return($sdev);
		}
		function fbCor($mood,$from,$to) {
			for($p=$from;$p<=$to;$p++) {
				$ncases++;
				$ax += $mood["forward"][$p];
				$ay += $mood["backward"][$p];
			}
			$ax = $ax / $ncases;
			$ay = $ay / $ncases;
			for($p=$from;$p<=$to;$p++) {
				$xt=$mood["forward"][$p]-$ax;
				$yt=$mood["backward"][$p]-$ay;
				$sxx += $xt*$xt;
				$syy += $yt*$yt;
				$sxy += $xt*$yt;
			}
			$correlation=$sxy/sqrt($sxx*$syy);
			return $correlation;
		}
		
		function isCorr($pIssue,$average_mood) { //compute product moment correlation of issue v and mood
			//produces vectors pr[v] and csign[v]
			foreach ($this->variable_names as $v) {
				$sxx=0;$sxy=0;$syy=0;$ax=0;$ay=0;$ncases=0;
				foreach ($average_mood as $year=>$average_mood_val) {
					if (!empty($pIssue[$year][$v])) {
						$ncases++;
						$ax += $pIssue[$year][$v];
						$ay += $average_mood_val;
					}
				}
				$ax = $ax/$ncases;  // xbar
				$ay = $ay/$ncases;  // ybar
				foreach ($average_mood as $year=>$average_mood_val) {
					if (!empty($pIssue[$year][$v])) {
						$xt=$pIssue[$year][$v]-$ax;
						$yt=$average_mood_val-$ay;
						$sxx += $xt*$xt;
						$syy += $yt*$yt;
						$sxy += $xt*$yt;
					}
				}
				$arr_return[$v]=$sxy/sqrt($sxx*$syy);
				if($arr_return[$v]<0) $this->sign[$v]=-1; else $this->sign[$v]=1;
			}
			return $arr_return;
		}
		function esmooth(&$mood,$alpha) {
			$Lb = 0.5;
			$Ub = 1;
			$Low = $Lb;
			$High = $Ub;
			$SSCrit = 0.001;
			$DeltInc = 0.0002;
			$VectAlpha = array();
			$Sum = array();
			$Dist = array();
			$X = array();
			if($alpha > 0) $alpha = 0.5;
			$VectAlpha[1] = $Lb;
			$VectAlpha[2] = 0.75;
			$VectAlpha[3] = $Ub;
			for($Ap=1;$Ap<=3;$Ap++) { //For Ap = 1 To 3 'AP is alpha pointer
				//Smooth:
				$alpha = $VectAlpha[$Ap];
				$X[1] = $mood[$this->years[0]];
				for($L=2;$L<=$this->nperiods;$L++) { //For L = 2 To Nperiods
					$X[$L] = $alpha * $mood[$this->years[$L-1]] + (1 - $alpha) * $X[$L - 1];
				}  //Next L
				$SumSq = 0;
				for($L=3;$L<=$this->nperiods;$L++) { //For L = 3 To Nperiods
					$FError = $mood[$this->years[$L-1]] - $X[$L - 1];
					$SumSq = $SumSq + $FError*$FError;
				}   //Return 'from smooth
				$Sum[$Ap] = $SumSq;
				$SSInit = $Sum[1];
				//Next Ap
			}
			$It = 0;
			$ItExit = false;
			while($ItExit==false) {
				$It++;
				for($L=1;$L<=3;$L++) { // Sorting the VectAlpha
					for($M=$L+1;$M<=3;$M++) {
						if($VectAlpha[$M] < $VectAlpha[$L]) {
							$TempReal = $VectAlpha[$M];
							$VectAlpha[$M] = $VectAlpha[$L];
							$VectAlpha[$L] = $TempReal;
							$TempReal = $Sum[$M];
							$Sum[$M] = $Sum[$L];
							$Sum[$L] = $TempReal;
						}
					}
				}
				$SSR12 = $Sum[1] - $Sum[2];
				$SSR23 = $Sum[2] - $Sum[3];
				$DInc12 = $VectAlpha[2] - $VectAlpha[1];
				$DInc23 = $VectAlpha[3] - $VectAlpha[2];
				if($It>=2) {
					if($SSR23>0) {
						$Low = $VectAlpha[2];
					}
					elseif ($SSR12 > 0) {
						$Low = $VectAlpha[1];
					}
					if($SSR12<0) {
						$High = $VectAlpha[2];
					}
					elseif ($SSR23 < 0) {
						$High = $VectAlpha[3];
					}//End If
					if($Low > $Lb) {
						$Lb = $Low;
					}
					if($High < $Ub) {
						$Ub = $High;
					}
				}
				if($DInc12 == 0 || $DInc23 == 0) {
					$VectAlpha[4] = 99;
				} else {
					$SSR12 = $SSR12 / $DInc12;
					$SSR23 = $SSR23 / $DInc23;
					$DdSSR = abs(($SSR23 - $SSR12) / ($DInc12 + $DInc23));
					if($It == 1) $OldD = $VectAlpha[2]; else $OldD = $VectAlpha[4];
					if($DdSSR != 0) {
						$VectAlpha[4] = $VectAlpha[2] + ((($SSR12 + $SSR23) / 2) / $DdSSR) / 2;
					} else {
						$VectAlpha[4] = 99;
					}  //End If
					$SetD = 0;
				}
				//'do random (within bounds) reassignment where out of bounds
				if($VectAlpha[4] < $Lb || $VectAlpha[4] > $Ub) {
					$rNumber = mt_rand()/mt_getrandmax();
					$VectAlpha[4] = $Lb + $rNumber * ($Ub - $Lb);
					$SetD = 1;
				}
				for($L=1;$L<=3;$L++) {
					//find max distance and discard
					$Dist[$L] = abs($VectAlpha[$L] - $VectAlpha[4]);
				}
				$Max = 1;
				$MaxD = $Dist[1];
				for($L=2;$L<=3;$L++) {
					if($Dist[$L]>$MaxD) {
						$TempReal = $MaxD;
						$MaxD = $Dist[$L];
						$Dist[$L] = $TempReal;
						$Max = $L;
					}
				}
				$VectAlpha[$Max] = $VectAlpha[4];
				$Ap = $Max;
				if($It == 1) {
					$OldSS = 100;
				} else {
					$OldSS = 100 * ($SumSq / $SSInit);
				}
				$alpha = $VectAlpha[$Ap];
				$X[1] = $mood[$this->years[0]];
				for($L=2;$L<=$this->nperiods;$L++) {
					$X[$L] = $alpha * $mood[$this->years[$L-1]] + (1 - $alpha) * $X[$L - 1];
				}
				$SumSq = 0;
				for($L=3;$L<=$this->nperiods;$L++) {
					$FError = $mood[$this->years[$L-1]] - $X[$L - 1];
					$SumSq = $SumSq + $FError*$FError;
				}
				$RelSum = 100 * ($SumSq / $SSInit);
				$Sum[$Max] = $SumSq;
				for($L=1;$L<=3;$L++) {
					for($M=$L+1;$M<=3;$M++) {
						if($VectAlpha[$M] < $VectAlpha[$L]) {
							$TempReal = $VectAlpha[$M];
							$VectAlpha[$M] = $VectAlpha[$L];
							$VectAlpha[$L] = $TempReal;
							$TempReal = $Sum[$M];
							$Sum[$M] = $Sum[$L];
							$Sum[$L] = $TempReal;
						}
					}
				}
				if(abs($OldSS - $RelSum) < $SSCrit && $VectAlpha[1] <= 0.995 && $VectAlpha[3] > 0.5005) $ItExit = true;
				$ParmDif = $OldD - $VectAlpha[4];
				if(abs($ParmDif) < $DeltInc) $ItExit = true;
				if(abs($Ub - $Lb) < 0.001) $ItExit = true;
				$MinA = 1;$MinSS = $Sum[1];
				for($L = 2;$L<=3;$L++) {
					if($Sum[$L] < $MinSS) {
						$MinSS = $Sum[$L];
						$MinA = $L;
					}
				}
				$Ap = $MinA;
				$alpha = $VectAlpha[$Ap];
				$X[1] = $mood[$this->years[0]];
				for($L=2;$L<=$this->nperiods;$L++) {
					$X[$L] = $alpha * $mood[$this->years[$L-1]] + (1 - $alpha) * $X[$L - 1];
				}
				$SumSq = 0;
				for($L=3;$L<=$this->nperiods;$L++) {
					$FError = $mood[$this->years[$L-1]] - $X[$L - 1];
					$SumSq = $SumSq + $FError*$FError;
				}
				if ( ($SetD == 1) && ($It < 51) ) {
					$ItExit = false; //reject fake solution
				}
			}
			return $VectAlpha[$MinA];
		}
		public function getData($arr_questions) {
			// CONNECT TO DB
			$conn = $this->connect();
			if ($conn != true) return $conn;
			$sql = "SELECT * FROM MoodAnnual WHERE variable_name IN ('".implode("','",$arr_questions)."')";
			$result  = mysql_query($sql);
			if (!($result)) {
				$err = mysql_error();
				die($err);
			}
			// GET YEAR RANGE
			$arr_years = array();
			while ($arr_agg = mysql_fetch_assoc($result)) {
				for($i=1952;$i<=2011;$i++) {
					if (!empty($arr_agg[$i]) && !in_array($i,$arr_years)) {
						$arr_years[] = $i;
					}
				}
			}
			$from = min($arr_years);
			$to = max($arr_years);
			// CREATE DATA ARRAY
			$data = array();
			mysql_data_seek($result, 0);
			while ($arr_agg = mysql_fetch_assoc($result)) {
				$v = $arr_agg["variable_name"];
				for($i=$from;$i<=$to;$i++) {
					$data[$v][$i] = $arr_agg[$i]; // Data: [variable name][year] = value of year
				}
			}
			$arr_return = $this->solve($data,$from,$to);
			return $arr_return;
		}
	}
?>