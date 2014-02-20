import java.io.*;
import java.util.*;

public class adwords {
	public static void main(String[] args){
		try {
			InputStreamReader is = new InputStreamReader(new FileInputStream("system.in"), "gbk");
			BufferedReader br = new BufferedReader(is);
			
			String readlineu = "";
			String readlinep = "";
			int num1 = 0;
			int num2 = 0;
			int num3 = 0;
			int num4 = 0;
			int num5 = 0;
			int num6 = 0;
			
			String usrname ="fff";
			String password = "fff";
			
			usrname =  br.readLine().split(" = ")[1];
			password = br.readLine().split(" = ")[1];
			num1 = Integer.parseInt(br.readLine().split(" = ")[1]);
			num2 = Integer.parseInt(br.readLine().split(" = ")[1]);
			num3 = Integer.parseInt(br.readLine().split(" = ")[1]);
			num4 = Integer.parseInt(br.readLine().split(" = ")[1]);
			num5 = Integer.parseInt(br.readLine().split(" = ")[1]);
			num6 = Integer.parseInt(br.readLine().split(" = ")[1]);
			
			br.close();
			is.close();
			
			Class.forName("oracle.jdbc.driver.OracleDriver");
			
			
			Runtime r1 = Runtime.getRuntime();
			Process p1=r1.exec("sqlplus "+usrname+"@orcl/"+password+"   @initial.sql");
			
			
			
			String s1;
			BufferedReader bufferedReader1 = new BufferedReader(new InputStreamReader(p1.getInputStream()));
			while((s1=bufferedReader1.readLine()) != null){
				System.out.println(s1);
				
			}
			p1.waitFor();
			
			
			
			Runtime r2 = Runtime.getRuntime();
			
			Process p2=r2.exec("sqlldr "+usrname+"@orcl/"+password+" control="+"queries.ctl");//
			String s2;
			BufferedReader bufferedReader2 = new BufferedReader(new InputStreamReader(p2.getInputStream()));
			while((s2=bufferedReader2.readLine()) != null)
				System.out.println(s2);
			p2.waitFor();
			
			
			Runtime r3 = Runtime.getRuntime();
			Process p3=r3.exec("sqlldr "+usrname+"@orcl/"+password+" control="+"advertisers.ctl");
			String s3;
			BufferedReader bufferedReader3 = new BufferedReader(new InputStreamReader(p3.getInputStream()));
			while((s3=bufferedReader3.readLine()) != null)
				System.out.println(s3);
			p3.waitFor();
			
			Runtime r4 = Runtime.getRuntime();
	        Process p4=r4.exec("sqlldr "+usrname+"@orcl/"+password+" control="+"keywords.ctl");
	        String s4;
			BufferedReader bufferedReader4 = new BufferedReader(new InputStreamReader(p4.getInputStream()));
			while((s4=bufferedReader4.readLine()) != null)
				System.out.println(s4);
			p4.waitFor();
			
			
			OutputStreamWriter wr1 = new  OutputStreamWriter(new FileOutputStream("task"+1+".sql"),"utf-8");
			PrintWriter pw1 = new PrintWriter(wr1);
			pw1.println("set serverout on;");
			pw1.println("execute proj("+num1+","+1+","+1+");");
			pw1.println("exit;");
			pw1.close();wr1.close();
			
			OutputStreamWriter wr2 = new OutputStreamWriter(new FileOutputStream("task"+2+".sql"),"utf-8");
			PrintWriter pw2 = new PrintWriter(wr2);
			pw2.println("set serverout on;");
			pw2.println("execute proj("+num2+","+1+","+2+");");
			pw2.println("exit;");
			pw2.close();wr2.close();
			
			OutputStreamWriter wr3 = new OutputStreamWriter(new FileOutputStream("task"+3+".sql"),"utf-8");
			PrintWriter pw3 = new PrintWriter(wr3);
			pw3.println("set serverout on;");
			pw3.println("execute proj("+num3+","+2+","+1+");");
			pw3.println("exit;");
			pw3.close();wr3.close();
			
			OutputStreamWriter wr4 = new OutputStreamWriter(new FileOutputStream("task"+4+".sql"),"utf-8");
			PrintWriter pw4 = new PrintWriter(wr4);
			pw4.println("set serverout on;");
			pw4.println("execute proj("+num1+","+2+","+2+");");
			pw4.println("exit;");
			pw4.close();wr4.close();
			
			OutputStreamWriter wr5 = new OutputStreamWriter(new FileOutputStream("task"+5+".sql"),"utf-8");
			PrintWriter pw5 = new PrintWriter(wr5);
			pw5.println("set serverout on;");
			pw5.println("execute proj("+num5+","+3+","+1+");");
			pw5.println("exit;");
			pw5.close();wr5.close();
			
			OutputStreamWriter wr6 = new OutputStreamWriter(new FileOutputStream("task"+6+".sql"),"utf-8");
			PrintWriter pw6 = new PrintWriter(wr6);
			pw6.println("set serverout on;");
			pw6.println("execute proj("+num6+","+3+","+2+");");
			pw6.println("exit;");
			pw6.close();wr6.close();
	
			for(int j=1;j<=6;j++){
	
				Process p5 = Runtime.getRuntime().exec("sqlplus "+usrname+"@orcl/"+password +" @adwords.sql" );
				
				
				
		        String s5;
				BufferedReader bufferedReader5 = new BufferedReader(new InputStreamReader(p5.getInputStream()));
				while((s5=bufferedReader5.readLine()) != null)
					System.out.println(s5);
				
				
				p5.waitFor();
				

			   Process p6 = Runtime.getRuntime().exec("sqlplus "+usrname+"@orcl/"+password+" @task"+j+".sql");
				

			ArrayList info = new ArrayList<String>();
			boolean start=false;
			boolean end=false;
			  
				
		    InputStreamReader isr = new InputStreamReader(p6.getInputStream(), "gbk");
			  BufferedReader bufread = new BufferedReader(isr);
			  
			  String info1 = "aa";
			  
			  while ( info1!= null) {
			    
			  
			    if((!start)&&info1.equals("begin!")){
		    	  	
			    	start=true;
			    }
			    if(info1.equals("end!")){
			    	end=true;
			    }
		    	    
			    if(start){
		    	     
				   info.add(info1);
			    }
			    if(end){
			    	 break;
			    }
			    
			    info1 = bufread.readLine();
			  }
				
			    info.remove(0);
				info.remove(info.size()-1);
				
				System.out.println("hhhhhhhhh");
				//System.out.println(jj);
			  			
				
				FileOutputStream fii = new FileOutputStream(
						"system.out."+j);
				
				System.out.println("dsfsdafadf");

				OutputStreamWriter ow = new OutputStreamWriter(fii,
						"utf-8");
				PrintWriter pw = new PrintWriter(ow);
				
				for (int ii = 0; ii < info.size(); ii++) {
					pw.println(info.get(ii));
				}
				
				
				bufread.close();
				isr.close();
				
				pw.close();
				ow.close();
				fii.close();
				
				
			}
					 
		}catch (Exception e){
			//throw e;
		}
	}
}
