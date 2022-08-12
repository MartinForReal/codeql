package generatedtest;

import java.io.File;
import java.io.InputStream;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.nio.channels.ReadableByteChannel;
import java.nio.charset.Charset;
import java.nio.file.Path;
import java.util.Scanner;
import java.util.regex.Pattern;

// Test case generated by GenerateFlowTestCase.ql
public class Test {

	Object source() {
		return null;
	}

	void sink(Object o) {}

	public void test() throws Exception {

		{
			// "java.util;Scanner;true;Scanner;;;Argument[0];Argument[-1];taint;manual"
			Scanner out = null;
			File in = (File) source();
			out = new Scanner(in);
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;Scanner;;;Argument[0];Argument[-1];taint;manual"
			Scanner out = null;
			File in = (File) source();
			out = new Scanner(in, (Charset) null);
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;Scanner;;;Argument[0];Argument[-1];taint;manual"
			Scanner out = null;
			File in = (File) source();
			out = new Scanner(in, (String) null);
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;Scanner;;;Argument[0];Argument[-1];taint;manual"
			Scanner out = null;
			InputStream in = (InputStream) source();
			out = new Scanner(in);
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;Scanner;;;Argument[0];Argument[-1];taint;manual"
			Scanner out = null;
			InputStream in = (InputStream) source();
			out = new Scanner(in, (Charset) null);
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;Scanner;;;Argument[0];Argument[-1];taint;manual"
			Scanner out = null;
			InputStream in = (InputStream) source();
			out = new Scanner(in, (String) null);
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;Scanner;;;Argument[0];Argument[-1];taint;manual"
			Scanner out = null;
			Path in = (Path) source();
			out = new Scanner(in);
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;Scanner;;;Argument[0];Argument[-1];taint;manual"
			Scanner out = null;
			Path in = (Path) source();
			out = new Scanner(in, (Charset) null);
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;Scanner;;;Argument[0];Argument[-1];taint;manual"
			Scanner out = null;
			Path in = (Path) source();
			out = new Scanner(in, (String) null);
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;Scanner;;;Argument[0];Argument[-1];taint;manual"
			Scanner out = null;
			Readable in = (Readable) source();
			out = new Scanner(in);
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;Scanner;;;Argument[0];Argument[-1];taint;manual"
			Scanner out = null;
			ReadableByteChannel in = (ReadableByteChannel) source();
			out = new Scanner(in);
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;Scanner;;;Argument[0];Argument[-1];taint;manual"
			Scanner out = null;
			ReadableByteChannel in = (ReadableByteChannel) source();
			out = new Scanner(in, (Charset) null);
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;Scanner;;;Argument[0];Argument[-1];taint;manual"
			Scanner out = null;
			ReadableByteChannel in = (ReadableByteChannel) source();
			out = new Scanner(in, (String) null);
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;Scanner;;;Argument[0];Argument[-1];taint;manual"
			Scanner out = null;
			String in = (String) source();
			out = new Scanner(in);
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;findInLine;;;Argument[-1];ReturnValue;taint;manual"
			String out = null;
			Scanner in = (Scanner) source();
			out = in.findInLine((Pattern) null);
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;findInLine;;;Argument[-1];ReturnValue;taint;manual"
			String out = null;
			Scanner in = (Scanner) source();
			out = in.findInLine((String) null);
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;findWithinHorizon;;;Argument[-1];ReturnValue;taint;manual"
			String out = null;
			Scanner in = (Scanner) source();
			out = in.findWithinHorizon((Pattern) null, 0);
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;findWithinHorizon;;;Argument[-1];ReturnValue;taint;manual"
			String out = null;
			Scanner in = (Scanner) source();
			out = in.findWithinHorizon((String) null, 0);
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;next;;;Argument[-1];ReturnValue;taint;manual"
			String out = null;
			Scanner in = (Scanner) source();
			out = in.next((Pattern) null);
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;next;;;Argument[-1];ReturnValue;taint;manual"
			String out = null;
			Scanner in = (Scanner) source();
			out = in.next((String) null);
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;next;;;Argument[-1];ReturnValue;taint;manual"
			String out = null;
			Scanner in = (Scanner) source();
			out = in.next();
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;nextBigDecimal;;;Argument[-1];ReturnValue;taint;manual"
			BigDecimal out = null;
			Scanner in = (Scanner) source();
			out = in.nextBigDecimal();
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;nextBigInteger;;;Argument[-1];ReturnValue;taint;manual"
			BigInteger out = null;
			Scanner in = (Scanner) source();
			out = in.nextBigInteger();
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;nextBigInteger;;;Argument[-1];ReturnValue;taint;manual"
			BigInteger out = null;
			Scanner in = (Scanner) source();
			out = in.nextBigInteger(0);
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;nextBoolean;;;Argument[-1];ReturnValue;taint;manual"
			boolean out = false;
			Scanner in = (Scanner) source();
			out = in.nextBoolean();
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;nextByte;;;Argument[-1];ReturnValue;taint;manual"
			byte out = 0;
			Scanner in = (Scanner) source();
			out = in.nextByte();
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;nextByte;;;Argument[-1];ReturnValue;taint;manual"
			byte out = 0;
			Scanner in = (Scanner) source();
			out = in.nextByte(0);
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;nextDouble;;;Argument[-1];ReturnValue;taint;manual"
			double out = 0;
			Scanner in = (Scanner) source();
			out = in.nextDouble();
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;nextFloat;;;Argument[-1];ReturnValue;taint;manual"
			float out = 0;
			Scanner in = (Scanner) source();
			out = in.nextFloat();
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;nextInt;;;Argument[-1];ReturnValue;taint;manual"
			int out = 0;
			Scanner in = (Scanner) source();
			out = in.nextInt();
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;nextInt;;;Argument[-1];ReturnValue;taint;manual"
			int out = 0;
			Scanner in = (Scanner) source();
			out = in.nextInt(0);
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;nextLine;;;Argument[-1];ReturnValue;taint;manual"
			String out = null;
			Scanner in = (Scanner) source();
			out = in.nextLine();
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;nextLong;;;Argument[-1];ReturnValue;taint;manual"
			long out = 0;
			Scanner in = (Scanner) source();
			out = in.nextLong();
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;nextLong;;;Argument[-1];ReturnValue;taint;manual"
			long out = 0;
			Scanner in = (Scanner) source();
			out = in.nextLong(0);
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;nextShort;;;Argument[-1];ReturnValue;taint;manual"
			short out = 0;
			Scanner in = (Scanner) source();
			out = in.nextShort();
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;nextShort;;;Argument[-1];ReturnValue;taint;manual"
			short out = 0;
			Scanner in = (Scanner) source();
			out = in.nextShort(0);
			sink(out); // $ hasTaintFlow
		}
		{
			// "java.util;Scanner;true;reset;;;Argument[-1];ReturnValue;value;manual"
			Scanner out = null;
			Scanner in = (Scanner) source();
			out = in.reset();
			sink(out); // $ hasValueFlow
		}
		{
			// "java.util;Scanner;true;skip;;;Argument[-1];ReturnValue;value;manual"
			Scanner out = null;
			Scanner in = (Scanner) source();
			out = in.skip((Pattern) null);
			sink(out); // $ hasValueFlow
		}
		{
			// "java.util;Scanner;true;skip;;;Argument[-1];ReturnValue;value;manual"
			Scanner out = null;
			Scanner in = (Scanner) source();
			out = in.skip((String) null);
			sink(out); // $ hasValueFlow
		}
		{
			// "java.util;Scanner;true;useDelimiter;;;Argument[-1];ReturnValue;value;manual"
			Scanner out = null;
			Scanner in = (Scanner) source();
			out = in.useDelimiter((Pattern) null);
			sink(out); // $ hasValueFlow
		}
		{
			// "java.util;Scanner;true;useDelimiter;;;Argument[-1];ReturnValue;value;manual"
			Scanner out = null;
			Scanner in = (Scanner) source();
			out = in.useDelimiter((String) null);
			sink(out); // $ hasValueFlow
		}
		{
			// "java.util;Scanner;true;useLocale;;;Argument[-1];ReturnValue;value;manual"
			Scanner out = null;
			Scanner in = (Scanner) source();
			out = in.useLocale(null);
			sink(out); // $ hasValueFlow
		}
		{
			// "java.util;Scanner;true;useRadix;;;Argument[-1];ReturnValue;value;manual"
			Scanner out = null;
			Scanner in = (Scanner) source();
			out = in.useRadix(0);
			sink(out); // $ hasValueFlow
		}

	}

}
